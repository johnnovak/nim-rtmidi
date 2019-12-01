# nim-rtmidi

*Work in progress, not ready for public consumption yet!*

This is a Nim wrapper for the [RtMidi](https://github.com/thestk/rtmidi)
cross-platform C++ MIDI library. **RtMidi** provides a common API for realtime
MIDI input/output across the following operating systems:

* Linux (ALSA, JACK)
* Mac OS X (CoreMIDI, JACK)
* Windows (Multimedia Library)

The wrapper supports both static and dynamic linking and provides a pleasant
Nim interface to the functions provided by the C API.

For more information please refer to the [official RtMidi
tutorial](https://www.music.mcgill.ca/~gary/rtmidi/index.html#license) and
check out the [Nim examples](/examples).

## Versioning

Versioning follows the `x.y.z.w` scheme, where `x.y.z` corresponds to the
RtMidi version being wrapped (e.g. `4.0.0`) and `w` to the patch version of the Nim
wrapper (e.g.  `4.4.0.1`).

## Installation

The best way to install the latest version of the package is via `nimble`:

```
nimble install rtmidi
```

## Examples

Compile and run any of the examples by running the following command
in the [examples](/examples) directory:
~~~
nim c -r -d:rtMidiStaticLib <example>
~~~

Alternatively, you can invoke the `examplesStatic` or `examples` (for dynamic
linking) nimble task in the project root directory to compile all examples:

```
nimble examplesStatic
```

### Statically linking to RtMidi

To link statically to RtMidi (the C sources are bundled within the module),
define the conditional symbol `rtMidiStaticLib` (`-d:rtMidiStaticLib` or
`--define:rtMidiStaticLib`).

## Documentation

TODO

## License

**RtMidi** is the copyright of Gary P. Scavone and is released under
a modified MIT license, with the added *feature* that modifications be sent to
the developer. This library is also released under the MIT license to avoid
confusion.

