use serde::Deserialize;
use serde_dhall;
use std::fs;
use std::io::Write;
use std::path::Path;
use std::process::Command;
use std::{self, collections::HashMap};

type Constr = &'static str;

const VERSION: Constr = "testing";
const SMELT_FILE: Constr = "Smelt.dhall";
const SMELT_STORE: Constr = ".smelt/";
const ERROR_PARSE_SMELTFILE: Constr = "Could not parse Smeltfile.dhall";

// Smeltfile types, these model the dhall ones
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
struct Buildspace {
    tmap: HashMap<String, Rule>,
}

impl From<Schema> for Buildspace {
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
        Buildspace { tmap }
    }
}

impl Buildspace {
    fn resolve(&self, target: &str) -> Vec<u8> {
        match self.tmap.get(target) {
            // artifact source
            Some(rule) => {
                println!("[CHECKING ARTIFACT] {}", target);
                // compute the current signature
                let mut input_hashes = vec![];
                for dep in rule.deps.iter() {
                    input_hashes.append(&mut self.resolve(dep));
                }
                let current_sign = get_signature(input_hashes);

                // compute the last signature
                let tokenp = Path::new(SMELT_STORE).join("sign/").join(&target);
                let past_sign = match fs::read(&tokenp) {
                    Ok(content) => content,
                    // in case the token doesnt already exist it is generated
                    Err(_e) => {
                        fs::create_dir_all(tokenp.parent().unwrap()).unwrap();
                        vec![]
                    }
                };

                // check if out-of-date
                if current_sign != past_sign || fs::metadata(target).is_err() {
                    println!("[BUILDING] {}", target);
                    exec(&rule.run);
                    fs::write(tokenp, current_sign).unwrap();
                } else {
                    // if up-to-date
                    println!("[SKIPPING] {}", target);
                }
            }
            // raw source
            None => {
                println!("[RETRIEVING SOURCE] {}", target);
            }
        };

        get_signature(fs::read(target).unwrap())
    }

    fn build(&self, target: &str) -> Result<(), anyhow::Error> {
        if !self.tmap.contains_key(target) {
            let _foo = anyhow::anyhow!("No target {} found", target);
        }
        self.resolve(target);
        Ok(())
    }
}

fn get_signature<T: AsRef<[u8]>>(data: T) -> Vec<u8> {
    let x: [u8; 16] = md5::compute(data).into();
    Vec::from(x)
}

fn exec(script: &[String]) {
    for line in script {
        println!("[RUNNING] {}", line);
        let out = Command::new("sh").arg("-c").arg(line).output().unwrap();
        std::io::stdout().write_all(&out.stdout).unwrap();
        std::io::stderr().write_all(&out.stderr).unwrap();
    }
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
    let buildspace = Buildspace::from(schema);
    if std::env::args().len() == 1 {
        println!("[ERROR] No targets specified!");
        return
    }
    for (i, argument) in std::env::args().enumerate() {
        if i != 0 {
            buildspace.build(&argument).unwrap();
        }
    }
    println!("Done!");
}
