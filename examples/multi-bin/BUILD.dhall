let db = ../../dhall/package.dhall
let BuildSchema = db.core.Schema
let Rule = db.core.Rule
let gcc = db.tool.gcc.gcc
let Binary = db.tool.gcc.Binary
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
    : BuidlSchema.Type
