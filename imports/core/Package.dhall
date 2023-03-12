{- List of targets to build -}

let SmeltNode = ./Node.dhall

let SmeltPackage: Type = List SmeltNode

in SmeltPackage