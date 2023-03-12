let spaceJoin = \(list: List Text) -> List/fold Text list Text (λ(x : Text) → λ(y : Text) → "${x} ${y}") ""

in spaceJoin