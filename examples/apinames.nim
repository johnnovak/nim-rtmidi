import strformat
import rtmidi

proc main() =
  let apis = rtmidi.getCompiledApis()
  echo "API names by identifier:"

  for api in apis:
    let name = api.name
    if name.len == 0:
      echo fmt"Invalid name for API {api}"
      quit(1)

    let displayName = api.displayName
    if displayName.len == 0:
      echo fmt"Invalid display name for API {api}"
      quit(1)

    echo fmt"* {ord(api)} '{name}': '{displayName}'"

main()
