import os,parseutils, strformat, terminal

import rtmidi


proc chooseInputPort(m: MidiIn): bool =
  let numPorts = m.numPorts
  case numPorts
  of 0:
    echo "No input ports available!"
  of 1:
    echo fmt"Opening {m.portName()}"
    m.openPort()
    result = true
  else:
    for i in 0..<numPorts:
      echo fmt"  Input port #{i}: {m.portName(i)}";

    var i = 1000
    while i >= numPorts:
      echo "\nChoose a port number: "
      discard parseInt($getch(), i)

    m.openPort(i)
    result = true


proc chooseOutputPort(m: MidiOut): bool =
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


var gClockCount = 0

proc midiInCallback(deltaTime: cdouble, message: ptr UncheckedArray[byte],
                    messageSize: csize, userData: pointer) {.cdecl.} =

  system.setupForeignThreadGc()

  # Ignore longer messages
  if messageSize == 1:
    case message[0]
    of 0xfa:
      echo "START received"
    of 0xfb:
      echo "CONTINUE received"
    of 0xfc:
      echo "STOP received"
    of 0xf8:
      inc(gClockCount)
      if gClockCount == 24:
        let bpm = 60.0 / 24.0 / deltaTime
        echo fmt"One beat, estimated BPM = {bpm}"
        gClockCount = 0
    else:
      gClockCount = 0


proc clockIn() =
  let midiIn = createDefaultMidiIn()
  if not chooseInputPort(midiIn):
    midiIn.close()
    quit(1)

  midiIn.setCallback(midiInCallback)
  midiIn.ignoreTypes(false, false, false)

  echo "Reading MIDI input... Press Q to quit."
  var c: char
  while c != 'q':
    sleep(10)
    c = getch()

  midiIn.close()


proc clockOut() =
  let midiOut = createDefaultMidiOut()
  if not chooseOutputPort(midiOut):
    midiOut.close()
    quit(1)

  var msg: array[1, byte]

  # Period in ms = 100 BPM
  # 100*24 ticks / 1 minute, so (60*1000) / (100*24) = 25 ms / tick
  var sleepMs = 25;
  echo fmt"Generating clock at {(60.0 / 24.0 / sleepMs.float * 1000.0)} BPM."

  # Send out a series of MIDI clock messages.
  # MIDI start
  msg[0] = 0xfa
  midiOut.sendMessage(msg, 1)
  echo "MIDI start"

  for i in 0..7:
    # MIDI continue
    msg[0] = 0xfb
    midiOut.sendMessage(msg, 1)
    echo "MIDI continue"

    for j in 0..95:
      # MIDI clock
      msg[0] = 0xf8
      midiOut.sendMessage(msg, 1)

      if (j mod 24 == 0):
        echo "MIDI clock (one beat)"
      sleep(sleepMs)

    # MIDI stop
    msg[0] = 0xfc
    midiOut.sendMessage(msg, 1)
    echo "MIDI stop"
    sleep(500)

  msg[0] = 0xfc
  midiOut.sendMessage(msg, 1)
  echo "MIDI stop"

  sleep(500)
  echo "Done!"
  midiOut.close()


proc exitUsage() =
  echo "Usage: midiclock <in|out>"
  quit(1)

proc main() =
  if paramCount() < 1:
    exitUsage()

  let mode = paramStr(1)
  case mode:
  of "in": clockIn()
  of "out": clockOut()
  else: exitUsage()


main()
