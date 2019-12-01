import strformat, rtmidi

proc main() =
  let apis = rtmidi.getCompiledApis()
  echo "Compiled APIs:"

  for api in apis:
    echo fmt"  {api.displayName}"
  echo ""

  var midiIn: MidiIn
  var midiOut: MidiOut

  try:
    midiIn = createDefaultMidiIn()
    echo fmt"Current input API: {midiIn.currentApi}"
    echo ""

    let numInPorts = midiIn.numPorts
    echo fmt"There are {numInPorts} MIDI input sources available."

    for i in 0..<numInPorts:
      echo fmt"  Input Port #{i}: {midiIn.portName(i)}"
    echo ""

    midiOut = createDefaultMidiOut()
    echo fmt"Current output API: {midiOut.currentApi}"
    echo ""

    let numOutPorts = midiOut.numPorts
    echo fmt"There are {numOutPorts} MIDI output ports available."

    for i in 0..<numOutPorts:
      echo fmt"  Output Port #{i}: {midiOut.portName(i)}"
    echo ""

    midiIn.close()
    midiOut.close()

  except RtMidiError as e:
    echo fmt"*** ERROR: {e.msg}"


main()
