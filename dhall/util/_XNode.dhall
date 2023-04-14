{-
    An eXpandable Node.
    Same as a Node, except you pass the source actual Node definitions, instead of their names.
    This simplifies modeling dependency trees.

    Related functions:
    expand.dhall
-}
let Node = ../core/Node.dhall

let XNode
    : Type
    = { art : List Text, cmd : List Text, src : List Node }

in  XNode