when not defined(rtMidiStaticLib):
  when defined(windows):
    const RtMidiDll = "rtmidi4.dll"
  elif defined(macosx):
    const RtMidiDll = "librtmidi4.dylib"
  else:
    const RtMidiDll = "librtmidi.so.4"

  {.pragma: rtMidiImport, dynlib: RtMidiDll.}

  {.deadCodeElim: on.}

else:
  when defined(windows):
    {.passC: "-std=gnu++11 -D__WINDOWS_MM__", passL: "-lstdc++ -lwinmm",
      compile: "src/RtMidi.cpp",
      compile: "src/rtmidi_c.cpp".}

  elif defined(macosx):
    {.passC: "-std=gnu++11 -D__MACOSX_CORE__",
      passL: "-framework CoreMIDI -framework CoreAudio -framework CoreFoundation",
      compile: "rtmidi/src/RtMidi.cpp",
      compile: "rtmidi/src/rtmidi_c.cpp".}

  elif defined(linux):
    when defined(rtMidiAlsa):
      {.passC: "-std=gnu++11 -D__LINUX_ALSA__", passL: "-lstdc++ -lasound -lpthread",
        compile: "rtmidi/src/RtMidi.cpp",
        compile: "rtmidi/src/rtmidi_c.cpp".}
    elif defined(rtMidiJack):
      {.passC: "-std=gnu++11 -D__UNIX_JACK__", passL: "-lstdc++ -ljack",
        compile: "rtmidi/src/RtMidi.cpp",
        compile: "rtmidi/src/rtmidi_c.cpp".}
    else:
      {.error: "define rtMidiAlsa or rtMidiJack (pass -d:... to compile)".}

  {.pragma: rtMIdiImport.}


type
  RtMidiWrapper* {.bycopy.} = object
    `ptr`*: pointer            ## ! The wrapped RtMidi object.
    data*: pointer             ## ! True when the last function call was OK.
    ok*: bool                  ## ! If an error occured (ok != true), set to an error message.
    msg*: cstring


## Typedef for a generic RtMidi pointer.

type
  RtMidiPtr* = ptr RtMidiWrapper

## Typedef for a generic RtMidiIn pointer.

type
  RtMidiInPtr* = ptr RtMidiWrapper

## Typedef for a generic RtMidiOut pointer.

type
  RtMidiOutPtr* = ptr RtMidiWrapper

## MIDI API specifier arguments.  See \ref RtMidi::Api.

type
  RtMidiApi* = enum
    RTMIDI_API_UNSPECIFIED,   ## !< Search for a working compiled API.
    RTMIDI_API_MACOSX_CORE,   ## !< Macintosh OS-X CoreMIDI API.
    RTMIDI_API_LINUX_ALSA,    ## !< The Advanced Linux Sound Architecture API.
    RTMIDI_API_UNIX_JACK,     ## !< The Jack Low-Latency MIDI Server API.
    RTMIDI_API_WINDOWS_MM,    ## !< The Microsoft Multimedia MIDI API.
    RTMIDI_API_RTMIDI_DUMMY,  ## !< A compilable but non-functional API.
    RTMIDI_API_NUM            ## !< Number of values in this enum.


## ! \brief Defined RtMidiError types. See \ref RtMidiError::Type.

type
  RtMidiErrorType* = enum
    RTMIDI_ERROR_WARNING,     ## !< A non-critical error.
    RTMIDI_ERROR_DEBUG_WARNING, ## !< A non-critical error which might be useful for debugging.
    RTMIDI_ERROR_UNSPECIFIED, ## !< The default, unspecified error type.
    RTMIDI_ERROR_NO_DEVICES_FOUND, ## !< No devices found on system.
    RTMIDI_ERROR_INVALID_DEVICE, ## !< An invalid device ID was specified.
    RTMIDI_ERROR_MEMORY_ERROR, ## !< An error occured during memory allocation.
    RTMIDI_ERROR_INVALID_PARAMETER, ## !< An invalid parameter was specified to a function.
    RTMIDI_ERROR_INVALID_USE, ## !< The function was called incorrectly.
    RTMIDI_ERROR_DRIVER_ERROR, ## !< A system driver error occured.
    RTMIDI_ERROR_SYSTEM_ERROR, ## !< A system error occured.
    RTMIDI_ERROR_THREAD_ERROR ## !< A thread error occured.


## ! \brief The type of a RtMidi callback function.
##
##  \param timeStamp   The time at which the message has been received.
##  \param message     The midi message.
##  \param userData    Additional user data for the callback.
##
##  See \ref RtMidiIn::RtMidiCallback.
##

type
  RtMidiCCallback* = proc (timeStamp: cdouble; message: ptr cuchar; messageSize: csize;
                        userData: pointer)

##  RtMidi API
## ! \brief Determine the available compiled MIDI APIs.
##
##  If the given `apis` parameter is null, returns the number of available APIs.
##  Otherwise, fill the given apis array with the RtMidi::Api values.
##
##  \param apis  An array or a null value.
##  \param apis_size  Number of elements pointed to by apis
##  \return number of items needed for apis array if apis==NULL, or
##          number of items written to apis array otherwise.  A negative
##          return value indicates an error.
##
##  See \ref RtMidi::getCompiledApi().
##

proc rtmidiGetCompiledApi*(apis: ptr RtMidiApi; apis_size: cuint): cint {.rtMidiImport, cdecl, importc: "rtmidi_get_compiled_api".}
## ! \brief Return the name of a specified compiled MIDI API.
## ! See \ref RtMidi::getApiName().

proc rtmidiApiName*(api: RtMidiApi): cstring {.rtMidiImport, cdecl, importc: "rtmidi_api_name".}
## ! \brief Return the display name of a specified compiled MIDI API.
## ! See \ref RtMidi::getApiDisplayName().

proc rtmidiApiDisplayName*(api: RtMidiApi): cstring {.rtMidiImport, cdecl, importc: "rtmidi_api_display_name".}
## ! \brief Return the compiled MIDI API having the given name.
## ! See \ref RtMidi::getCompiledApiByName().

proc rtmidiCompiledApiByName*(name: cstring): RtMidiApi {.rtMidiImport, cdecl, importc: "rtmidi_compiled_api_by_name".}
## ! \internal Report an error.

proc rtmidiError*(`type`: RtMidiErrorType; errorString: cstring) {.rtMidiImport, cdecl, importc: "rtmidi_error".}
## ! \brief Open a MIDI port.
##
##  \param port      Must be greater than 0
##  \param portName  Name for the application port.
##
##  See RtMidi::openPort().
##

proc rtmidiOpenPort*(device: RtMidiPtr; portNumber: cuint; portName: cstring) {.rtMidiImport, cdecl, importc: "rtmidi_open_port".}
## ! \brief Creates a virtual MIDI port to which other software applications can
##  connect.
##
##  \param portName  Name for the application port.
##
##  See RtMidi::openVirtualPort().
##

proc rtmidiOpenVirtualPort*(device: RtMidiPtr; portName: cstring) {.rtMidiImport, cdecl, importc: "rtmidi_open_virtual_port".}
## ! \brief Close a MIDI connection.
##  See RtMidi::closePort().
##

proc rtmidiClosePort*(device: RtMidiPtr) {.rtMidiImport, cdecl, importc: "rtmidi_close_port".}
## ! \brief Return the number of available MIDI ports.
##  See RtMidi::getPortCount().
##

proc rtmidiGetPortCount*(device: RtMidiPtr): cuint {.rtMidiImport, cdecl, importc: "rtmidi_get_port_count".}
## ! \brief Return a string identifier for the specified MIDI input port number.
##  See RtMidi::getPortName().
##

proc rtmidiGetPortName*(device: RtMidiPtr; portNumber: cuint): cstring {.rtMidiImport, cdecl, importc: "rtmidi_get_port_name".}
##  RtMidiIn API
## ! \brief Create a default RtMidiInPtr value, with no initialization.

proc rtmidiInCreateDefault*(): RtMidiInPtr {.rtMidiImport, cdecl, importc: "rtmidi_in_create_default".}
## ! \brief Create a  RtMidiInPtr value, with given api, clientName and queueSizeLimit.
##
##   \param api            An optional API id can be specified.
##   \param clientName     An optional client name can be specified. This
##                         will be used to group the ports that are created
##                         by the application.
##   \param queueSizeLimit An optional size of the MIDI input queue can be
##                         specified.
##
##  See RtMidiIn::RtMidiIn().
##

proc rtmidiInCreate*(api: RtMidiApi; clientName: cstring; queueSizeLimit: cuint): RtMidiInPtr {.rtMidiImport, cdecl, importc: "rtmidi_in_create".}
## ! \brief Free the given RtMidiInPtr.

proc rtmidiInFree*(device: RtMidiInPtr) {.rtMidiImport, cdecl, importc: "rtmidi_in_free".}
## ! \brief Returns the MIDI API specifier for the given instance of RtMidiIn.
## ! See \ref RtMidiIn::getCurrentApi().

proc rtmidiInGetCurrentApi*(device: RtMidiPtr): RtMidiApi {.rtMidiImport, cdecl, importc: "rtmidi_in_get_current_api".}
## ! \brief Set a callback function to be invoked for incoming MIDI messages.
## ! See \ref RtMidiIn::setCallback().

proc rtmidiInSetCallback*(device: RtMidiInPtr; callback: RtMidiCCallback,
                            userData: pointer) {.rtMidiImport, cdecl, importc: "rtmidi_in_set_callback".}
## ! \brief Cancel use of the current callback function (if one exists).
## ! See \ref RtMidiIn::cancelCallback().

proc rtmidiInCancelCallback*(device: RtMidiInPtr) {.rtMidiImport, cdecl, importc: "rtmidi_in_cancel_callback".}
## ! \brief Specify whether certain MIDI message types should be queued or ignored during input.
## ! See \ref RtMidiIn::ignoreTypes().

proc rtmidiInIgnoreTypes*(device: RtMidiInPtr; midiSysex: bool; midiTime: bool;
                            midiSense: bool) {.rtMidiImport, cdecl, importc: "rtmidi_in_ignore_types".}
## ! Fill the user-provided array with the data bytes for the next available
##  MIDI message in the input queue and return the event delta-time in seconds.
##
##  \param message   Must point to a char* that is already allocated.
##                   SYSEX messages maximum size being 1024, a statically
##                   allocated array could
##                   be sufficient.
##  \param size      Is used to return the size of the message obtained.
##
##  See RtMidiIn::getMessage().
##

proc rtmidiInGetMessage*(device: RtMidiInPtr; message: ptr cuchar; size: ptr csize): cdouble {.rtMidiImport, cdecl, importc: "rtmidi_in_get_message".}
##  RtMidiOut API
## ! \brief Create a default RtMidiInPtr value, with no initialization.

proc rtmidiOutCreateDefault*(): RtMidiOutPtr {.rtMidiImport, cdecl, importc: "rtmidi_out_create_default".}
## ! \brief Create a RtMidiOutPtr value, with given and clientName.
##
##   \param api            An optional API id can be specified.
##   \param clientName     An optional client name can be specified. This
##                         will be used to group the ports that are created
##                         by the application.
##
##  See RtMidiOut::RtMidiOut().
##

proc rtmidiOutCreate*(api: RtMidiApi; clientName: cstring): RtMidiOutPtr {.rtMidiImport, cdecl, importc: "rtmidi_out_create".}
## ! \brief Free the given RtMidiOutPtr.

proc rtmidiOutFree*(device: RtMidiOutPtr) {.rtMidiImport, cdecl, importc: "rtmidi_out_free".}
## ! \brief Returns the MIDI API specifier for the given instance of RtMidiOut.
## ! See \ref RtMidiOut::getCurrentApi().

proc rtmidiOutGetCurrentApi*(device: RtMidiPtr): RtMidiApi {.rtMidiImport, cdecl, importc: "rtmidi_out_get_current_api".}
## ! \brief Immediately send a single message out an open MIDI output port.
## ! See \ref RtMidiOut::sendMessage().

proc rtmidiOutSendMessage*(device: RtMidiOutPtr; message: ptr cuchar; length: cint): cint {.rtMidiImport, cdecl, importc: "rtmidi_out_send_message".}
## ! }@
