{- imports -}
let db = ../../dhall/package.dhall
let SmeltSchema = db.core.Schema
let gcc     = db.tool.gcc.gcc
let Binary  = db.tool.gcc.Binary
let Library = db.tool.gcc.Library


in SmeltSchema :: { version = "testing", package = [

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

]}
