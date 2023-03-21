use serde::Deserialize;
use serde_dhall;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::{self, collections::HashMap};
use std::fs;

type Constr = &'static str;

const VERSION: Constr = "testing";
const SMELT_FILE: Constr = "Smelt.dhall";
const SMELT_STORE: Constr = ".smelt/";
const ERROR_PARSE_SMELTFILE: Constr = "Could not parse Smeltfile.dhall";

// Smeltfile types, these model the dhall ones

// imports/SmeltNode.dhall
#[derive(Deserialize, Debug)]
struct Node {
    art: Vec<String>,
    src: Vec<String>,
    cmd: Vec<String>,
}

type ExplodedNode = (Vec<String>, Vec<String>, Vec<String>);

impl Into<ExplodedNode> for Node {
    fn into(self) -> ExplodedNode {
        (self.art, self.src, self.cmd)
    }
}

// imports/SmeltSchema.dhall
#[derive(Deserialize)]
struct Schema {
    version: String,
    package: Vec<Node>,
}

// Build types
#[derive(Debug)]
struct Rule {
    run: Vec<String>,
    deps: Vec<String>,
}

impl Rule {
    fn new(run: Vec<String>, deps: Vec<String>) -> Self {
        Self { run, deps }
    }
}

// Parsed schema
#[derive(Debug)]
struct BuildGraph {
    tmap: HashMap<String, Rule>,
}

impl From<Schema> for BuildGraph {
    fn from(schema: Schema) -> Self {
        let mut tmap = HashMap::with_capacity(schema.package.len());
        for node in schema.package.into_iter() {
            let (artifacts, sources, commands) = node.into();
            for out in artifacts.into_iter() {
                // not the most efficient way of doing this because we copy `sources` and `commands` a bunch of times,
                // instead of storing a ref to them or something
                tmap.insert(out, Rule::new(commands.clone(), sources.clone()));
            }
        }
        BuildGraph { tmap }
    }
}

impl BuildGraph {
    fn resolve(&self, target: &str) -> Result<Vec<u8>, anyhow::Error> {
        match self.tmap.get(target) {
            // artifact source
            Some(rule) => {
                println!("[CHECKING ARTIFACT] {}", target);
                // compute the current input signature

                let mut input_hashes = vec![];
                for dep in rule.deps.iter() { // read all dependencies, can be slow
                    input_hashes.append(&mut self.resolve(dep)?);
                }
                // using the commands as an input makes the builds more correct
                input_hashes.append(&mut get_signature(rule.run.join("")));
                let current_sign = get_signature(input_hashes);

                // find its token that holds the previous sign
                // .smelt/sign/{full-filename-and-path}.md5
                let mut token = Path::new(SMELT_STORE).join("sign/").join(&target).into_os_string();
                token.push(".md5");
                let token = PathBuf::from(token);

                let past_sign = match fs::read(&token) {
                    Ok(content) => content,
                    // in case the token doesnt already exist it is generated
                    Err(_e) => {
                        fs::create_dir_all(token.parent().unwrap())?;
                        vec![]
                    }
                };

                // check if out-of-date
                if current_sign != past_sign || fs::metadata(target).is_err() {
                    println!("[BUILDING] {}", target);
                    exec(&rule.run)?;
                    fs::write(token, current_sign)?;
                } else {
                    // if up-to-date
                    println!("[SKIPPING] {}", target);
                }
                println!();
            }
            // raw source
            None => {
                println!("---> [RETRIEVING SOURCE] {}", target);
            }
        };

        Ok(get_signature(fs::read(target)?))
    }

    fn build(&self, target: &str) -> Result<(), anyhow::Error> {
        if !self.tmap.contains_key(target) {
            let _foo = anyhow::anyhow!("No target {} found", target);
        }
        self.resolve(target)?;
        Ok(())
    }
}

fn get_signature<T: AsRef<[u8]>>(data: T) -> Vec<u8> {
    let x: [u8; 16] = md5::compute(data).into();
    Vec::from(x)
}

fn exec(script: &[String]) -> Result<(), anyhow::Error> {
    for line in script {
        println!("---> [RUNNING] {}", line);
        let out = Command::new("sh").arg("-c").arg(line).output()?;
        std::io::stdout().write_all(&out.stdout)?;
        std::io::stderr().write_all(&out.stderr)?;
    }
    Ok(())
}

fn main() {
    let schema: Schema = serde_dhall::from_file(SMELT_FILE)
        .parse()
        .expect(ERROR_PARSE_SMELTFILE);
    if schema.version != VERSION {
        panic!(
            "Unsupported version '{0}', required '{1}'",
            schema.version, VERSION
        );
    }
    let graph = BuildGraph::from(schema);
    if std::env::args().len() == 1 {
        println!("[ERROR] No targets specified!");
        return;
    }
    for (i, argument) in std::env::args().enumerate() {
        if i != 0 {
            graph.build(&argument).unwrap();
        }
    }
    println!("Done!");
}
