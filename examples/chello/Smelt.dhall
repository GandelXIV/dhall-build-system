{- imports -}
let SmeltSchema = ../../imports/core/Schema.dhall
let gcc = ../../imports/tool/gcc/gcc.dhall
let Binary = ../../imports/tool/gcc/Binary.dhall
let Library = ../../imports/tool/gcc/Library.dhall

let objs = [ "main.o", "lib.o", "config.o" ]

let pkg1 = [

gcc Binary :: {
  output = Some "hello",
  files = objs, 
},

gcc Library :: {
  files = [ "main.c" ],
  addsrc = [ "lib.h", "config.h" ]
},

gcc Library :: {
  files = [ "lib.c" ],
  addsrc = [ "lib.h" ]
},

gcc Library :: {
  files = [ "config.c" ],
  addsrc = [ "config.h" ]
}

]

in  { version = "testing", package = pkg1 } : SmeltSchema
