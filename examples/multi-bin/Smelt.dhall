let smelt = ../../imports/package.dhall
let SmeltSchema = smelt.core.Schema
let Rule = smelt.core.Rule
let gcc = smelt.tool.gcc.gcc
let Binary = smelt.tool.gcc.Binary
let List/map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/map.dhall

let targets = [ "cat", "demo", "hello" ]

in    { version = "testing"
      , package =
          List/map
            Text
            Rule
            ( \(t : Text) ->
                gcc Binary::{ output = Some t, files = [ "src/${t}.c" ] }
            )
            targets
      }
    : SmeltSchema.Type
