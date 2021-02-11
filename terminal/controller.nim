import options
import std/terminal
import times
import ../models


var
  channel: Channel[Command]
  inputThread: Thread[void]

proc readUserInput() =
  while true:
    let ch = getch()
    case ch
    of 'w': channel.send(North)
    of 'a': channel.send(West)
    of 's': channel.send(South)
    of 'd': channel.send(East)
    of 'q':
      channel.send(Quit)
      break
    else: discard

proc initController*() =
  channel.open()
  createThread(inputThread, readUserInput)

proc getCommand*(timeout = 1): Option[Command] =
  let start = now()
  let timeout = initDuration(milliseconds=timeout)
  while true:
    let response = channel.tryRecv()
    if response.dataAvailable:
      result = some(response.msg)
    else:
      break
    if now() - start > timeout:
      break

proc finishController*() =
  channel.close()
  inputThread.joinThread()
