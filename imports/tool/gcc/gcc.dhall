{-
    Converts a tool.gcc.Config into a Rule
-}
let Build = ../../util/Build.dhall

let ToolRule = ./ToolRule.dhall

let spaceJoin = ../../util/spaceJoin.dhall

let replace =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/Text/replace.dhall

let gcc =
      \(conf : ToolRule) ->
        let cmd =
                  "gcc ${spaceJoin conf.files}"
              ++  (if conf.object then "-c " else "")
              ++  merge
                    { None = "", Some = \(o : Text) -> "-o ${o}" }
                    conf.output

        in  Build :: {
            , art =
              [ merge
                  { None =
                      if    conf.object
                      then  merge
                              { None = "a.out"
                              , Some = \(name : Text) -> replace ".c" ".o" name
                              }
                              (List/head Text conf.files)
                      else  "a.out"
                  , Some = \(i : Text) -> i
                  }
                  conf.output
              ]
            , src = conf.files # conf.addsrc
            , cmd = [ cmd ]
            }


let _example0 = assert :
    gcc {
        files = [ "main.c" ],
        object = True,
        output = None Text,
        addsrc = [ "conf.h", "lib.h" ]
    }
    ===
    Build :: {
        art = [ "main.o" ],
        src = [ "main.c", "conf.h", "lib.h" ],
        cmd = [ "gcc main.c -c " ]
    }

let _example1 = assert :
    gcc {
        files = [ "a.o", "b.o", "c.o" ],
        object = False,
        output = Some "app.exec",
        addsrc = [] : List Text,
    }
    ===
    Build :: {
        art = [ "app.exec" ],
        src = [ "a.o", "b.o", "c.o" ],
        cmd = [ "gcc a.o b.o c.o -o app.exec" ]
    }


in  gcc
