import os,parseutils, strformat, terminal

import rtmidi


proc chooseMidiPort(m: MidiOut): bool =
  echo "\nWould you like to open a virtual output port? [y/N]"
  if getch() == 'y':
    m.openVirtualPort()
    result = true
  else:
    let numPorts = m.numPorts
    case numPorts
    of 0:
      echo "No output ports available!"
    of 1:
      echo fmt"Opening {m.portName()}"
      m.openPort()
      result = true
    else:
      for i in 0..<numPorts:
        echo fmt"  Output port #{i}: {m.portName(i)}";

      var i = 1000
      while i >= numPorts:
        echo "\nChoose a port number: "
        discard parseInt($getch(), i)

      m.openPort(i)
      result = true


proc main() =
  let midiOut = createDefaultMidiOut()
  if not chooseMidiPort(midiOut):
    midiOut.close()
    quit(1)

  var msg: array[10, byte]

  # Send out a series of MIDI messages.

  # Program change: 192, 5
  msg[0] = 192
  msg[1] = 5
  midiOut.sendMessage(msg, 2)

  sleep(500)

  msg[0] = 0xF1
  msg[1] = 60
  midiOut.sendMessage(msg, 2)

  # Control Change: 176, 7, 100 (volume)
  msg[0] = 176
  msg[1] = 7
  msg[2] = 100
  midiOut.sendMessage(msg, 3)

  # Note On: 144, 64, 90
  msg[0] = 144
  msg[1] = 64
  msg[2] = 90
  midiOut.sendMessage(msg, 3)

  sleep(500)

  # Note Off: 128, 64, 40
  msg[0] = 128
  msg[1] = 64
  msg[2] = 40
  midiOut.sendMessage(msg, 3)

  sleep(500)

  # Control Change: 176, 7, 40
  msg[0] = 176
  msg[1] = 7
  msg[2] = 40
  midiOut.sendMessage(msg, 3)

  sleep(500)

  # Sysex: 240, 67, 4, 3, 2, 247
  msg[0] = 240
  msg[1] = 67
  msg[2] = 4
  msg[3] = 3
  msg[4] = 2
  msg[5] = 247
  midiOut.sendMessage(msg, 6)

  midiOut.close()


main()

