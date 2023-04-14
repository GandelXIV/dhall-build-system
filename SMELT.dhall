let smelt = ./dhall/package.dhall
let Schema = smelt.core.Schema
let Build = smelt.util.Build

in Schema :: { version = "testing", package=[

Build :: {
    art = [ "target/release/smelt" ],
    src = [ "cli/main.rs", "Cargo.toml", "Cargo.lock" ],
    cmd = [ "cargo build --release" ]
}

]}
