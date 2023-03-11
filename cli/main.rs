use serde::Deserialize;
use serde_dhall;
use std::{self, collections::HashMap};
use std::fs;
use std::io::Read;
use std::error::Error;
use std::path::{Path, PathBuf};
use anyhow::anyhow;

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
type Buildspace = HashMap<String, Rule>;

impl From<Schema> for Buildspace {
    fn from(schema: Schema) -> Self {
        let mut bs = HashMap::with_capacity(schema.package.len());
        for node in schema.package.into_iter() {
            let (artifacts, sources, commands) = node.into();
            for out in artifacts.into_iter() {
                // not the most efficient way of doing this because we copy `sources` and `commands` a bunch of times, 
                // instead of storing a ref to them or something
                bs.insert(out, Rule::new(commands.clone(), sources.clone()));
            }
        }
        bs
    }
}


// We determine this by maintaining hash tokens of each source file's content
// TODO: match star patterns in the fname path, such as /* and /**
fn outdated<P: AsRef<Path>>(fname: P) -> Result<bool, anyhow::Error> {
    // hash of the file
    let current: [u8; 16] = md5::compute(fs::read(&fname)?).into();

    // path to its token
    let tokenp = Path::new(SMELT_STORE).join("hash/").join(fname);

    let past = match fs::read(&tokenp) {
        Ok(content) => content,
        // in case the token doesnt already exist it is generated
        Err(e) => {
            fs::create_dir_all(tokenp.parent().ok_or(anyhow!("Could not generate token"))?);
            fs::write::<PathBuf, [u8; 16]>(tokenp, current.into())?;
            return Ok(true);
        }
    };

    // if both hashes dont match, a new hash is recalculated and we rebuild
    if current != *past {
        fs::write::<PathBuf, [u8; 16]>(tokenp, current.into())?;
        return Ok(true)
    }

    // otherwise keep it as it is
    Ok(false)
}

fn main() {
    let schema: Schema = serde_dhall::from_file(SMELT_FILE)
        .parse()
        .expect(ERROR_PARSE_SMELTFILE);
    if schema.version != VERSION {
        panic!("Unsupported version '{0}', required '{1}'", schema.version, VERSION);
    }
    let buildspace = Buildspace::from(schema);
    println!("{:?}", buildspace);
    println!("{:?}", outdated("src/cat.c"));
    println!("Done!");
}
