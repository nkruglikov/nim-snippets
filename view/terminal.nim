import std/terminal
import ../models

import options
import times


template writeAt(text: untyped; x, y: int) =
  setCursorPos(x, y)
  stdout.write(text)

proc display*(grid: Grid) =
  for x in 0 ..< grid.w + 2:
    "-".writeAt(x, 0)
    "-".writeAt(x, grid.h + 1)
  for y in 1 ..< grid.h + 1:
    "|".writeAt(0, y)
    "|".writeAt(grid.w + 1, y)
  for y in 0 ..< grid.h:
    for x in 0 ..< grid.w:
      grid[x, y].writeAt(x + 1, y + 1)
  stdout.flushFile()

proc initView*() =
  hideCursor()
  eraseScreen()

proc finishView*() =
  eraseScreen()
  showCursor()
  setCursorPos(0, 0)


var channel: Channel[Command]
var inputThread: Thread[void]

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
