{-
    A function that returns the artifacts of a List of Rules.
-}

let List/map =
      https://prelude.dhall-lang.org/v11.1.0/List/map
        sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let List/concat =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/concat.dhall

let Rule = ../core/Rule.dhall


let artifacts =
      \(pack : List Rule) ->
        let isolated
            : List (List Text)
            = List/map Rule (List Text) (\(i : Rule) -> i.art) pack

        in  List/concat Text isolated


let _example0 =
        assert
      :     artifacts
              [ { art = [ "a" ], src = [ "" ], cmd = [ "" ] }
              , { art = [ "b", "c" ], src = [ "" ], cmd = [ "" ] }
              , { art = [ "d" ], src = [ "" ], cmd = [ "" ] }
              ]
        ===  [ "a", "b", "c", "d" ]


in  artifacts
