let SmeltSchema = ../../imports/core/Schema.dhall

let create =
      \(target : Text) ->
        let input = "src/${target}.c"

        in  { art = [ target ]
            , src = [ input ]
            , cmd = [ "gcc ${input} -o ${target}" ]
            }

let pkg = [ create "hello", create "cat", create "demo" ]

in  { version = "testing", package = pkg } : SmeltSchema
