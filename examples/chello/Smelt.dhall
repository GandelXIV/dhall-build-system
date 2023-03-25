{- imports -}
let smelt = ../../imports/package.dhall
let SmeltSchema = smelt.core.Schema
let gcc     = smelt.tool.gcc.gcc
let Binary  = smelt.tool.gcc.Binary
let Library = smelt.tool.gcc.Library


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
