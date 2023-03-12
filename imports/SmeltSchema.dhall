let SmeltNode = ./SmeltNode.dhall
let SmeltPackage = ./SmeltPackage.dhall

let SmeltSchema: Type = {
    version: Text,
    package: SmeltPackage,
}

in SmeltSchema