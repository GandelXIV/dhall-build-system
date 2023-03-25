let smelt = ./imports/package.dhall
let Schema = smelt.core.Schema
let Build = smelt.util.Build
let copy = ./imports/tool/copy.dhall

in { version="testing", package=[

copy ["target/release/smelt"] False "~/.local/bin/",

Build :: {
    art=[ "target/release/smelt" ],
    src=[ "cli/main.rs", "Cargo.toml", "Cargo.lock" ],
    cmd=[ "cargo build --release" ]
},

] } : Schema
