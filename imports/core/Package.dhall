{- 
    List of targets to build.
    Provide a context for creating build graphs.
-}

let Rule = ./Rule.dhall

let Package: Type = List Rule

in Package