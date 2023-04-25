let smelt = ../../dhall/package.dhall
let Schema = smelt.core.Schema
let spaceJoin = smelt.util.spaceJoin

let ccobj = 
    \(target : Text) -> 
    \(headers : List Text) -> {
        art = [ "${target}.o" ],
        cmd = [ "gcc -c ${target}.c -o ${target}.o" ],
        src = [ "${target}.c" ] # headers
    }


let objects = [ "main.o", "lib.o", "config.o" ]
let hello = {
    art = [ "hello" ],
    src = objects,
    cmd = [ "gcc ${spaceJoin objects} -o hello" ]
}

let obj_main = ccobj "main" [ "lib.h", "config.h" ]
let obj_lib = ccobj "lib" [ "lib.h" ]
let obj_conf = ccobj "config" [ "config.h" ]

in Schema :: { 
    version = "testing", 
    package=[ hello, obj_main, obj_lib, obj_conf ] 
}