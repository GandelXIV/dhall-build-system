{- Main type for Smeltfiles -}

let SmeltPackage = ./Package.dhall

{- Currently, only the "testing" version is supported -}
let SmeltSchema: Type = {
    version: Text,
    package: SmeltPackage,
}

in SmeltSchema