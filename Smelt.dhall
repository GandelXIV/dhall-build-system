let smelt = ./imports/Smelt.dhall

let pkg = [{
    art=["target/debug/smelt"],
    src=["cli/main.rs", "Cargo.toml", "Cargo.lock"],
    cmd=["cargo build"]
}]

in { version="testing", package=pkg } : smelt.core.Schema