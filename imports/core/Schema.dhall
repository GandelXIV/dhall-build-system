{- Main type for Smelt.dhall -}

let SmeltNode = ./Node.dhall
let SmeltPackage = ./Package.dhall

{- Currently, only the "testing" version is supported -}
let SmeltSchema: Type = {
    version: Text,
    package: SmeltPackage,
}

in SmeltSchema