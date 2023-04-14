let ToolRule = ./ToolRule.dhall

let Library = {
    Type = ToolRule,
    default = {
        object = True,
        output = None Text,
        addsrc = [] : List Text,
    }
}

in Library