{-
    Simple way to just define rules that copy.
-}

let Build = ../util/Build.dhall
let spaceJoin = ../util/spaceJoin.dhall
let List/map = https://raw.githubusercontent.com/dhall-lang/dhall-lang/v21.1.0/Prelude/List/map.dhall

let copy =
    \(source : List Text) ->
    \(directory : Bool) ->
    \(destination : Text) ->
        Build :: {
            art = if directory
                then List/map
                    Text
                    Text
                    (\(file : Text) -> "${destination}/${file}")
                    source
                else [ destination ],
            src = source,
            cmd = [ "cp ${spaceJoin source} ${destination}" ]
        }


let _example0 = assert :
    copy [ "foo" ] False "bar"
    ===
    Build :: {
        art = [ "bar" ],
        src = [ "foo" ],
        cmd = [ "cp foo  bar" ]
    }

let _example1 = assert : 
    copy [ "A", "B", "C" ] True "mydir"
    ===
    Build :: {
        art = [ "mydir/A", "mydir/B", "mydir/C" ],
        src = [ "A", "B", "C" ],
        cmd = [ "cp A B C  mydir" ]
    }


in copy