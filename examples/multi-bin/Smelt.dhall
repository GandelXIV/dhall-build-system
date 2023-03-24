let SmeltSchema = ../../imports/core/Schema.dhall

let Rule = ../../imports/core/Rule.dhall

let gcc = ../../imports/tool/gcc/gcc.dhall

let Binary = ../../imports/tool/gcc/Binary.dhall

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
    : SmeltSchema
