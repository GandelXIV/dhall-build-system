let db = ./dhall/package.dhall
let Schema = db.core.Schema
let Build = db.util.Build

in Schema :: { version = "testing", package=[

Build :: {
    art = [ "target/release/dhall-build" ],
    src = [ "cli/main.rs", "Cargo.toml", "Cargo.lock" ],
    cmd = [ "cargo build --release" ]
}

]}
