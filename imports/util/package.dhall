let workdir = ./workdir.dhall
let spaceJoin = ./spaceJoin.dhall
let artifacts = ./getArtifacts.dhall
let Build = ./Build.dhall

-- deprecated
--let expand = ./expand.dhall
--let XNode = ./XNode.dhall

in {
    workdir,
    spaceJoin,
    artifacts,
    Build
}