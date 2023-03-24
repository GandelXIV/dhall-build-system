let Config = ./Config.dhall

let Library = {
    Type = Config,
    default = {
        object = True,
        output = None Text,
        addsrc = [] : List Text,
    }
}

in Library