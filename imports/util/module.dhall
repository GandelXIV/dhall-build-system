{-
    Create a rule that builds targets from another smeltfile.
-}

let Build = ./Build.dhall
let workdir = ./workdir.dhall
let spaceJoin = ./spaceJoin.dhall
let List/map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/map.dhall


let module =
    \(path : Text) ->
    \(targets : List Text) ->
        Build :: {
            art = List/map 
                Text
                Text
                (\(t : Text) -> "${path}/${t}")
                targets,
            src = [] : List Text {- Sources are handled by the smeltfile -}, 
            cmd = workdir path [ "smelt build ${spaceJoin targets}" ],
        }

let _example0 = assert : 
    module "project" [ "hello", "demo" ]
    ===
    Build :: {
      art = [ "project/hello", "project/demo" ]
    , cmd = [ "cd project && smelt build hello demo " ]
    , src = [] : List Text
    }

in module
