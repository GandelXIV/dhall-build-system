let db = ../dhall/package.dhall
let module = db.util.module
let Schema = db.core.Schema

in Schema :: { package = [

module "chello" [ "hello" ],
module "multi-bin" [ "demo", "cat", "hello" ]

]}
