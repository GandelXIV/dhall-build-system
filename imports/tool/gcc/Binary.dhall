let ToolRule = ./ToolRule.dhall

let Binary = {
    Type = ToolRule,
    default = {
        object = False,
        output = None Text,
        addsrc = [] : List Text,
    }
}

in Binary