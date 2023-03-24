{- imports -}
let SmeltSchema = ../../imports/core/Schema.dhall

let spaceJoin = ../../imports/util/spaceJoin.dhall

let build = ../../imports/util/build.dhall


{- Builds an object file with gcc -}
let compile_object =
      \(name : Text) ->
      \(headers : List Text) ->
        let out = "bin/${name}.o"

        let main = "${name}.c"

        in  { art = [ out ]
            , src = [ main ] # headers
            , cmd = [ "mkdir -p bin/", "gcc -c ${name}.c -o ${out}" ]
            }

let objs = [ "bin/main.o", "bin/lib.o", "bin/config.o" ]

{- approach #1 -}
let pkg1 = [

  build::{ 
    art = [ "hello" ], 
    src = objs, 
    cmd = [ "gcc ${spaceJoin objs} -o hello" ]
  },

  compile_object "main" [ "lib.h", "config.h" ],

  compile_object "lib" [ "lib.h" ],
  
  compile_object "config" [ "config.h" ]

]

in  { version = "testing", package = pkg1 } : SmeltSchema
