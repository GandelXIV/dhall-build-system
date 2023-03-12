let SmeltSchema = ../../imports/SmeltSchema.dhall

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