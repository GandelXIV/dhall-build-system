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

in  spaceJoin
