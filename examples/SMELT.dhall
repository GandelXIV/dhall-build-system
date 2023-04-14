let smelt = ../dhall/package.dhall
let module = smelt.util.module
let Schema = smelt.core.Schema

in Schema :: { package = [

module "chello" [ "hello" ],
module "multi-bin" [ "demo", "cat", "hello" ]

]}
