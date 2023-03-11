{- prelude -}


let SmeltNode: Type = {
    art: List Text,
    src: List Text,
    cmd: List Text,
}

let SmeltPackage: Type = List SmeltNode

let SmeltSchema: Type = {
    version: Text,
    package: SmeltPackage
}

{- Defintion -}

let build = \(target: Text) ->
    let input = "src/${target}.c"
    in {
        art=[target],
        src=[input],
        cmd=["gcc ${input} -o ${target}"]
    }

let pkg = [
    build "hello",
    build "cat",
    build "demo"
]

in { version="testing", package=pkg } : SmeltSchema