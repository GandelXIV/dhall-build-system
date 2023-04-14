{-
    Doc:
    files > 
    object > `-c` flag
    output > `-o` flag followed by a file
    addsrc > additional sources
-}

let ToolRule: Type =  {
    files: List Text,
    object: Bool,
    output: Optional Text,
    addsrc: List Text,
}

in ToolRule