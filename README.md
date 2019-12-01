# nim-rtmidi

*Work in progress, not ready for public consumption yet!*

This is a Nim wrapper for the [RtMidi](https://github.com/thestk/rtmidi)
cross-platform C++ MIDI library. **RtMidi** provides a common API for realtime
MIDI input/output across the following operating systems:

* Linux (ALSA, JACK)
* Mac OS X (CoreMIDI, JACK)
* Windows (Multimedia Library)

The wrapper provides a pleasant Nim interface to the functions provided by the
C API.

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
nim c -r <example>
~~~

Alternatively, you can invoke the `examples` nimble task in the project root
directory to compile all examples:

```
nimble examples
```

### Selecting the target API

On Windows, the Windows Multimedia Library is always used so there's no need
to configure anything.

On OS X, the symbols `rtMidiCore` or `rtMidiJack` need to be provided to
indicate which API(s) to compile the library for (note that only CoreMIDI has
been tested).

On Linux, the symbols `rtMidiAlsa` or `rtMidiJack` need to be provided to
indicate which API(s) to compile the library for (note that Linux has not been
tested at all).


## Documentation

TODO

## License

**RtMidi** is the copyright of Gary P. Scavone and is released under
a modified MIT license, with the added *feature* that modifications be sent to
the developer. This library is also released under the MIT license to avoid
confusion.

