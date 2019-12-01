# Package

version     = "0.1.0"
author      = "John Novak <john@johnnovak.net>"
description = "Nim wrapper for the cross-platform C++ RtMidi library"
license     = "MIT"

skipDirs = @["examples"]

requires "nim >= 1.0.4"

task examples, "Compiles the examples with dynamic linking":
  exec "nim c examples/apinames"
  exec "nim c examples/midiout"
  exec "nim c examples/midiprobe"
