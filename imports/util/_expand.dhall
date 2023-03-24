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

let List/concat =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/concat.dhall

{-
let _example1 =
        assert
      :     expand
              { art = [ "A" ]
              , cmd = [ "-" ]
              , src =
                  List/concat
                    Node
                    [ expand
                        { art = [ "B" ]
                        , cmd = [ "-" ]
                        , src =
                          [ { art = [ "C" ], cmd = [ "-" ], src = [ "c" ] }
                          , { art = [ "D" ], cmd = [ "-" ], src = [ "d" ] }
                          ]
                        }
                    , [ { art = [ "E" ], cmd = [ "-" ], src = [ "e" ] }
                      , { art = [ "F" ], cmd = [ "-" ], src = [ "f" ] }
                      ]
                    ]
              }
        ===  [ { art = [ "A" ], cmd = [ "-" ], src = [ "B", "E", "F" ] }
             , { art = [ "B" ], cmd = [ "-" ], src = [ "C", "D" ] }
             , { art = [ "C" ], cmd = [ "-" ], src = [ "c" ] }
             , { art = [ "D" ], cmd = [ "-" ], src = [ "d" ] }
             , { art = [ "E" ], cmd = [ "-" ], src = [ "e" ] }
             , { art = [ "F" ], cmd = [ "-" ], src = [ "f" ] }
             ]
-}

in  expand