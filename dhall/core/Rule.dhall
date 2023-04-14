{- 
    Building block of Packages.

    Each rule has the following fields:
    art -> artifacts, corresponding to build targets
    src -> sources, files artifacts depend on
    cmd -> shell commands to generate the artifacts

    When an artifact is to be build, sources are scanned for changes.
    If none are found, the build is [SKIPPED].
    Otherwise a rebuild is triggered, and all the commands are executed.
-}

let Rule: Type = {
    art: List Text,
    src: List Text,
    cmd: List Text,
}

in Rule