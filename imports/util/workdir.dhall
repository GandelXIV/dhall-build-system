{-
    Set the working directory for Rule commands.

    It works by prepending `cd {dir} &&` to all subcommands
-}

let workdir =
      \(dir : Text) ->
      \(commands : List Text) ->
        List/fold
          Text
          (List/reverse Text commands)
          (List Text)
          (\(x : Text) -> \(new : List Text) -> new # [ "cd ${dir} && ${x}" ])
          ([] : List Text)


let _example0 =
        assert
      :     workdir "project/" [ "./configure", "make" ]
        ===  [ "cd project/ && ./configure", "cd project/ && make" ]


in  workdir
