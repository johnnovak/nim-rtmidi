import rtmidi/wrapper

type
  RtMidiHandle = wrapper.RtMidiWrapperPtr

  MidiIOObj = object of RootObj
    handle: RtMidiHandle

  MidiInObj  = object of MidiIOObj
  MidiOutObj = object of MidiIOObj

  MidiIO   = ref MidiIOObj
  MidiIn*  = ref MidiInObj
  MidiOut* = ref MidiOutObj

#type
#  MidiInCallback* = proc (timeStamp: float, message: openArray[byte]) {.closure.}

type
  RtMidiError* = object of Exception

converter toHandle(m: MidiIO):  RtMidiHandle = m.handle


template handleError(m: MidiIO) =
  if not m.handle.ok:
    raise newException(RtMidiError, $m.handle.msg)

template withHandleError(m: MidiIO, body: untyped): auto =
  body
  handleError(m)


#var g_MidiInCallbackInternal: wrapper.RtMidiCallback

# General

proc getCompiledApis*(): set[MidiApi] =
  var apis: array[ord(MidiApi.high)-1, MidiApi]
  let apiCount = wrapper.getCompiledApi(nil, 0)
  discard wrapper.getCompiledApi(apis[0].addr, apiCount.cuint)
  result = {}
  for i in 0..<apiCount:
    result.incl(apis[i])

export wrapper.name
export wrapper.displayName
export wrapper.getCompiledApiByName


# Midi Input

proc createDefaultMidiIn*(): MidiIn =
  new(result)
  result.handle = wrapper.createDefaultMidiIn()
  handleError(result)

proc createMidiIn*(api: MidiApi = maUnspecified,
                   clientName: string = "RtMidi Input Client",
                   queueSize: Natural = 100): MidiIn =
  new(result)
  result.handle = wrapper.createMidiIn(api, clientName, queueSize.cuint)
  handleError(result)

proc close*(m: MidiIn) = withHandleError(m):
  wrapper.freeMidiIn(m)

proc currentApi*(m: MidiIn): MidiApi = withHandleError(m):
  result = wrapper.getCurrentMidiInApi(m)

proc openPort*(m: MidiIn,
               portName: string = "RtMidi Input") = withHandleError(m):
  wrapper.openPort(m, 0, portName)

proc openPort*(m: MidiIn, portNumber: Natural,
               portName: string = "RtMidi Input") = withHandleError(m):
  wrapper.openPort(m, portNumber.cuint, portName)

proc openVirtualPort*(m: MidiIn,
                      portName: string = "RtMidi Input") = withHandleError(m):
  wrapper.openVirtualPort(m, portName)

proc setCallback*(m: MidiIn, callback: RtMidiCallback) = withHandleError(m):
#  g_MidiInCallbackInternal = proc (deltaTime: cdouble,
#                                   message: ptr UncheckedArray[byte],
#                                   messageSize: csize,
#                                   userData: pointer) {.cdecl.} =
#
#    callback(timeStamp, toOpenArray(message, 0, messageSize))
#
#  wrapper.setCallback(m, g_MidiInCallbackInternal, nil)
  wrapper.setCallback(m, callback, nil)

proc cancelCallback*(m: MidiIn) = withHandleError(m):
  wrapper.cancelCallback(m)

proc ignoreTypes*(m: MidiIn, midiSysEx: bool = true, midiTime: bool = true,
                  midiSense: bool = true) = withHandleError(m):
  wrapper.ignoreTypes(m, midiSysEx, midiTime, midiSense)

proc getNextMessage*(m: MidiIn,
                     buffer: var openArray[byte]): tuple[length: Natural,
                                                         eventDelta: float] =
  withHandleError(m):
    var length: csize
    var eventDelta = wrapper.getMessage(m, buffer[0].addr, length.addr)
    result = (length.Natural, eventDelta)


# Midi Output

proc createDefaultMidiOut*(): MidiOut =
  new(result)
  result.handle = wrapper.createDefaultMidiOut()
  handleError(result)

proc createMidiOut*(api: MidiApi = maUnspecified,
                    clientName: string = "RtMidi Output Client"): MidiOut =
  new(result)
  result.handle = wrapper.createMidiOut(api, clientName)
  handleError(result)

proc close*(m: MidiOut) = withHandleError(m):
  wrapper.freeMidiOut(m)

proc currentApi*(m: MidiOut): MidiApi = withHandleError(m):
  result = wrapper.getCurrentMidiOutApi(m)

proc openPort*(m: MidiOut,
               portName: string = "RtMidi Output") = withHandleError(m):
  wrapper.openPort(m, 0, portName)

proc openPort*(m: MidiOut, portNumber: Natural,
               portName: string = "RtMidi Output") = withHandleError(m):
  wrapper.openPort(m, portNumber.cuint, portName)

proc openVirtualPort*(m: MidiOut,
                      portName: string = "RtMidi Output") = withHandleError(m):
  wrapper.openVirtualPort(m, portName)

proc sendMessage*(m: MidiOut, message: var openArray[byte],
                  len: Natural) = withHandleError(m):
  discard wrapper.sendMessage(m, message[0].addr, len.cint)


# Common Midi In/Out

proc numPorts*(m: MidiIO): Natural = withHandleError(m):
  result = wrapper.portCount(m)

proc portName*(m: MidiIO): string = withHandleError(m):
  result = $wrapper.portName(m, 0)

proc portName*(m: MidiIO, portNumber: Natural): string = withHandleError(m):
  result = $wrapper.portName(m, portNumber.cuint)

