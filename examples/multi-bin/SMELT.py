import smelt
from smelt import build

build(
    art=["hello"],
    src=["src/hello.c"],
    cmd=["gcc src/hello.c -o hello"]
)

build(
    art=["cat"],
    src=["src/cat.c"],
    cmd=["gcc src/cat.c -o cat"]
)

build(
    art=["demo"],
    src=["src/demo.c"],
    cmd=["gcc src/demo.c -o demo"]
)

smelt.generate()
