from dataclasses import dataclass
import json

VERSION = "testing"

# global state
pkg = []

@dataclass
class Rule:
    art: list[str]
    src: list[str]
    cmd: list[str]

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__, 
            sort_keys=True, indent=4)

@dataclass
class Schema:
    version: str
    package: list[Rule]

    def toJSON(self):
        return json.dumps(self, default=lambda o: o.__dict__, 
            sort_keys=True, indent=4)

# public

def build(art=[], src=[], cmd=[]):
    global pkg
    pkg.append(Rule(
        art=art,
        src=src,
        cmd=cmd,
    ))

def generate():
    print(Schema(version=VERSION, package=pkg).toJSON())

