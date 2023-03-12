{- Main type for Smelt.dhall -}

let SmeltNode = ./SmeltNode.dhall
let SmeltPackage = ./SmeltPackage.dhall

{- Currently, only the "testing" version is supported -}
let SmeltSchema: Type = {
    version: Text,
    package: SmeltPackage,
}

in SmeltSchema