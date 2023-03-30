let smelt = ../imports/package.dhall
let module = smelt.util.module
let Schema = smelt.core.Schema

in { version="testing", package = [

module "chello" [ "hello" ],
module "multi-bin" [ "demo", "cat", "hello" ]

] } : Schema