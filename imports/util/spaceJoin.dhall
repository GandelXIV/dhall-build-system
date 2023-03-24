{-
    Connects Texts in a List with spaces to form a single string.
    Useful when embedding sources into commands.

    Example:
    "ld ${spaceJoin ['foo.o', 'bar.o', 'clam.o']}"
    Evaluates to:
    "ld foo.o bar.o clam.o "
-}

let spaceJoin =
      λ(list : List Text) →
        List/fold Text list Text (λ(x : Text) → λ(y : Text) → "${x} ${y}") ""


let _example0 = assert : spaceJoin [ "a", "b", "c" ] ≡ "a b c "


let _objects = [ "foo.o", "lib.o", "clam.o" ]

let _target =
      { art = [ "app" ]
      , src = _objects
      , cmd = [ "gcc ${spaceJoin _objects} -o app" ]
      }

let _example1 =
        assert
      :   _target
        ≡ { art = [ "app" ]
          , src = [ "foo.o", "lib.o", "clam.o" ]
          , cmd = [ "gcc foo.o lib.o clam.o  -o app" ]
          }


in  spaceJoin
