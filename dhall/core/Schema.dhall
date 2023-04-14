{- Main type for Smeltfiles -}

let SmeltPackage = ./Package.dhall

{- Currently, only the "testing" version is supported -}
let Schema = {
    Type = {
        version: Text,
        package: SmeltPackage,
    },
    default = {
        version = "testing",
        package = [] : SmeltPackage
    }
}

in Schema