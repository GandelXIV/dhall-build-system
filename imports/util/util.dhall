let workdir = ./workdir.dhall
let spaceJoin = ./spaceJoin.dhall
let artifacts = ./getArtifacts.dhall
let build = ./build.dhall

-- deprecated
--let expand = ./expand.dhall
--let XNode = ./XNode.dhall

in {
    workdir,
    spaceJoin,
    artifacts,
    build
}