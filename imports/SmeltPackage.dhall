{- List of targets to build -}

let SmeltNode = ./SmeltNode.dhall

let SmeltPackage: Type = List SmeltNode

in SmeltPackage