{-
    A function that expands an XNode into a List of Nodes.
-}
let XNode = ./XNode.dhall

let Node = ../core/Node.dhall

let artifacts = ./getArtifacts.dhall

let expand =
      \(x : XNode) ->
        [ { art = x.art, cmd = x.cmd, src = artifacts x.src } ] # x.src

let _example0 =
        assert
      :     expand
              { art = [ "app.exe" ]
              , cmd = [ "gcc main.o util64.o abclib.o" ]
              , src =
                [ { art = [ "main.o" ]
                  , src = [ "main.c" ]
                  , cmd = [ "gcc main.c" ]
                  }
                , { art = [ "util64.o", "abclib.o" ]
                  , src = [ "genlibs.sh" ]
                  , cmd = [ "./genlibs.sh" ]
                  }
                ]
              }
        ===  [ { art = [ "app.exe" ]
               , src = [ "main.o", "util64.o", "abclib.o" ]
               , cmd = [ "gcc main.o util64.o abclib.o" ]
               }
             , { art = [ "main.o" ]
               , src = [ "main.c" ]
               , cmd = [ "gcc main.c" ]
               }
             , { art = [ "util64.o", "abclib.o" ]
               , src = [ "genlibs.sh" ]
               , cmd = [ "./genlibs.sh" ]
               }
             ]

in  expand
