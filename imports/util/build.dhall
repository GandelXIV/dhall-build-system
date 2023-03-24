{-
    Implementation of the builder pattern for Rules.
    Takes same arguments as a regular Node except all fields are optional.
-}

let Rule = ../core/Rule.dhall

let T: Type = List Text

let empty = [] : T

let build = {
    Type = Rule,
    default = {
        art = empty,
        src = empty,
        cmd = empty,
    }
}


let _example0 = 
    assert :
    
    build::{
        cmd = ["echo foo bar"]
    }
    ===
    {
        art = empty,
        src = empty,
        cmd = ["echo foo bar"],
    }

let _example1 = 
    assert :

    build::{
        art = ["foo.txt"],
        cmd = ["echo bar > foo.txt"],
    }
    ===
    {
        art = ["foo.txt"],
        cmd = ["echo bar > foo.txt"],
        src = empty
    }


in build