let Config = ./Config.dhall

let Binary = {
    Type = Config,
    default = {
        object = False,
        output = None Text,
        addsrc = [] : List Text,
    }
}

in Binary