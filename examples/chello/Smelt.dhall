let SmeltSchema = ../../imports/SmeltSchema.dhall

let spaceJoin = ../../imports/spaceJoin.dhall

let compile_object =
      \(name : Text) ->
      \(headers : List Text) ->
        let out = "${name}.o"

        let main = "${name}.c"

        in  { art = [ out ]
            , src = [ main ] # headers
            , cmd = [ "gcc -c ${name}.c -o ${out}" ]
            }

let link_objects =
      \(output : Text) ->
      \(objects : List Text) ->
        { art = [ output ]
        , src = objects
        , cmd = [ "gcc -o ${output} ${spaceJoin objects}" ]
        }

let pkg1 =
      [ link_objects "hello" [ "main.o", "lib.o" ]
      , compile_object "main" [ "lib.h", "config.h" ]
      , compile_object "lib" [ "lib.h" ]
      ]

in  { version = "testing", package = pkg1 } : SmeltSchema
