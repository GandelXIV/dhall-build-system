use async_recursion::async_recursion;
use clap::{Parser, Subcommand};
use dashmap::DashMap;
use serde::{Deserialize, Serialize};
use serde_json;
use std::ffi::OsString;
use std::fs;
use std::future::Future;
use std::io::Write;
use std::os::unix::fs::MetadataExt;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::SystemTime;
use std::{self, collections::HashMap};
use tokio;

type Constr = &'static str;

const VERSION: Constr = "testing";
const SMELT_STORE: Constr = ".smelt/";
const SMELT_STATE: Constr = ".smelt/state/";
const ERROR_PARSE_SMELTFILE: Constr = "Could not parse Smeltfile.dhall";
const SMELT_FILE: Constr = "SMELT.dhall";
const SMELT_FINAL_FILE: Constr = ".smelt/Smelt.json";

// Smeltfile types, these model the dhall ones

// imports/Rule.dhall
#[derive(Deserialize, Debug)]
struct Rule {
    art: Vec<String>,
    src: Vec<String>,
    cmd: Vec<String>,
}

type ExplodedRule = (Vec<String>, Vec<String>, Vec<String>);

impl Into<ExplodedRule> for Rule {
    fn into(self) -> ExplodedRule {
        (self.art, self.src, self.cmd)
    }
}

impl Into<ExplodedRule> for &Rule {
    fn into(self) -> ExplodedRule {
        (self.art.clone(), self.src.clone(), self.cmd.clone())
    }
}

// imports/Schema.dhall
#[derive(Deserialize)]
struct Schema {
    version: String,
    package: Vec<Rule>,
}

impl Schema {
    // Convert into a stand-alone Makefile.
    // Note that many smelt-specific behaviour will be lost.
    fn into_gnumake(&self) -> String {
        let mut makefile = String::new();
        for rule in &self.package {
            let (artifacts, sources, commands): ExplodedRule = rule.into();
            let name = artifacts.join(" ");
            let deps = sources.join(" ");
            let recp = commands.join("\n\t");
            makefile.push_str(&format!("{name}: {deps}\n\t{recp}"));
            makefile.push('\n');
            makefile.push('\n');
        }
        makefile
    }
}

// Build types

#[derive(Debug)]
struct Node {
    commands: Vec<String>,
    sources: Vec<String>,
}

impl Node {
    fn new(commands: Vec<String>, sources: Vec<String>) -> Self {
        Self { commands, sources }
    }
}

// Parsed schema
struct BuildGraph {
    // https://en.wikipedia.org/wiki/Directed_acyclic_graph
    dag: HashMap<String, Node>,
    // content hash bakery kekw
    chb: DashMap<String, Box<dyn Future<Output = anyhow::Result<CHash>>>>,
}

impl From<Schema> for BuildGraph {
    fn from(schema: Schema) -> Self {
        let mut dag = HashMap::with_capacity(schema.package.len());
        for rule in schema.package.into_iter() {
            let (artifacts, sources, commands) = rule.into();
            for out in artifacts.into_iter() {
                // not the most efficient way of doing this because we copy `sources` and `commands` a bunch of times,
                // instead of storing a ref to them or something
                dag.insert(out, Node::new(commands.clone(), sources.clone()));
            }
        }
        let chb = DashMap::new();
        BuildGraph { dag, chb }
    }
}


// All dependency state
// tokens store previous dependency state in small files
struct State<'a> {
    meta: MetaToken,
    srcs: HashMap<&'a str, SourceToken>
}

#[derive(Debug, Serialize, Deserialize)]
struct SourceToken {
    chash: CHash,
    size: u64, // actually length
}

impl Default for SourceToken {
    fn default() -> Self {
        Self {
            chash: [0; 16],
            size: 0,
        }
    }
}

#[derive(Debug, Serialize, Deserialize)]
struct MetaToken {
    reciepe: Vec<String>,
}

impl Default for MetaToken {
    fn default() -> Self {
        Self { reciepe: vec![] }
    }
}


impl Drop for BuildGraph {
    fn drop(&mut self) {
        todo!("Flush chash DAG to .smelt");
    }
}

impl BuildGraph {
    #[async_recursion(?Send)]
    async fn resolve(&self, target: String) {
        println!("[ RESOLVE ] {}", target);
        match self.dag.get(&target) {
            // artifact source
            Some(node) => {
                // rebuild sources & start baking their respective hashes
                for s in node.sources.iter() {
                    self.resolve(s.clone()).await;
                }

                // Fetch past state

                let mut path2metatoken = OsString::from(SMELT_STATE);
                path2metatoken.push(&target);
                path2metatoken.push(".json");
                let mtoken: MetaToken = match &fs::read(&path2metatoken) {
                    Ok(data) => {
                        serde_json::from_slice(data).expect("Could not parse artifact token")
                    }
                    Err(_) => MetaToken::default(),
                };

                let mut stokens: HashMap<&str, SourceToken> = HashMap::new();
                for source in node.sources.iter() {
                    let mut tokename = OsString::from(&target);
                    tokename.push(".json");
                    let spath = PathBuf::from(SMELT_STATE).join(&target).join(tokename);
                    stokens.insert(
                        source,
                        match &fs::read(spath) {
                            Ok(data) => {
                                serde_json::from_slice(data).expect("Could not parse source token")
                            }
                            Err(_) => SourceToken::default(),
                        },
                    );
                }

                let past = State {
                    meta: mtoken,
                    srcs: stokens
                };

            }
            // raw source
            None => {
                //println!("---> [RETRIEVING SOURCE] {}", target);
            }
        };
        self.qchash(target);
    }

    fn qchash(&self, target: String) {
        if !self.chb.contains_key(&target) {
            println!("[ QCHASH ] {}", target);
            self.chb
                .insert(target.to_string(), Box::new(content_hash(target)));
        }
    }

    async fn build(&self, target: String) -> Result<(), anyhow::Error> {
        // content hash bakery lol
        if !self.dag.contains_key(&target) {
            return Err(anyhow::anyhow!("No target {} found", target));
        }
        let finale = self.resolve(target).await;
        Ok(())
    }
}

// stands for Content HASH, aliased in case we change hash formats
type CHash = [u8; 16];

// returns an empty vector on error
async fn content_hash<P: AsRef<Path>>(filename: P) -> Result<CHash, anyhow::Error> {
    let data = fs::read(filename)?;
    Ok(md5::compute(data).into())
}

fn exec(script: &[String]) -> Result<(), anyhow::Error> {
    for line in script {
        println!("RUN {}", line);
        let out = Command::new("bash").arg("-c").arg(line).output()?;
        std::io::stdout().write_all(&out.stdout)?;
        std::io::stderr().write_all(&out.stderr)?;
        assert!(out.status.success());
    }
    Ok(())
}

fn get_mtime<P: AsRef<Path>>(p: P) -> i64 {
    match fs::metadata(p) {
        Ok(meta) => meta.mtime(),
        Err(_) => 0,
    }
}

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Generate one or more targets
    Build {
        targets: Vec<String>,
        /// Target all possible artifacts
        #[arg(short, long)]
        all: bool,
    },
    /// Convert Smeltfile to a Makefile
    ToMake,
}

#[tokio::main]
async fn main() {
    let cli = Cli::parse();
    let start_time = SystemTime::now();

    //    exec(&["echo $PATH".to_string()]);
    //    exec(&["echo PATH".to_string()]);
    //    exec(&["DOG=yo echo $DOG".to_string()]);

    // dhall schema gets compiled down to JSON
    // This is also inremental & minimal
    let jason = if get_mtime(SMELT_FILE) > get_mtime(SMELT_FINAL_FILE) {
        println!("[INFO] Regenerating Schema.json");
        let build0 = Command::new("dhall-to-json")
            .arg("--file")
            .arg(SMELT_FILE)
            .output()
            .unwrap();
        print!("{}", std::str::from_utf8(&build0.stderr).unwrap());
        assert!(build0.status.success());

        // create directory to store json
        // creat_dir_all returns an error if the dir already exists, which we can safely ignore
        #[allow(unused_must_use)]
        fs::create_dir_all(SMELT_STORE);

        fs::write(SMELT_FINAL_FILE, &build0.stdout).unwrap();
        build0.stdout
    } else {
        fs::read(SMELT_FINAL_FILE).unwrap()
    };

    let schema: Schema = serde_json::from_slice(&jason).expect(ERROR_PARSE_SMELTFILE);
    if schema.version != VERSION {
        panic!(
            "Unsupported version '{0}', required '{1}'",
            schema.version, VERSION
        );
    }

    match &cli.command {
        Commands::Build { targets, all } => {
            if targets.len() == 0 && !*all {
                println!("No targets specified!");
                return;
            }

            let graph = BuildGraph::from(schema);

            if *all {
                for (target, _) in &graph.dag {
                    graph.build(target.to_string()).await.unwrap();
                }
            } else {
                for target in targets {
                    graph.build(target.to_string()).await.unwrap();
                }
            }
            println!(
                "Finished in {} seconds",
                start_time.elapsed().unwrap().as_secs_f64()
            );
        }
        Commands::ToMake => {
            println!("{}", schema.into_gnumake());
        }
    }
}
