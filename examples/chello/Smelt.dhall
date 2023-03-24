{- imports -}
let SmeltSchema = ../../imports/core/Schema.dhall
let gcc = ../../imports/tool/gcc/gcc.dhall
let Binary = ../../imports/tool/gcc/Binary.dhall
let Library = ../../imports/tool/gcc/Library.dhall

in { version = "testing", package = [

gcc Binary :: {
  output = Some "hello",
  files = [ "main.o", "lib.o", "config.o" ], 
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

]} : SmeltSchema
