{-
    Set the working directory for Node commands.

    Usage example:
    let cmd = workdir "lib/" ["./configure", "make"]
-}

let workdir =
      \(dir : Text) ->
      \(commands : List Text) ->
        List/fold
          Text
          commands
          (List Text)
          (\(x : Text) -> \(old : List Text) -> old # ["cd ${dir} && ${x}"])
          ([]: List Text)


in workdir "lib/" ["./configure", "make"]
{- in  workdir -}
