import std/terminal
import ../models


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
  showCursor()
