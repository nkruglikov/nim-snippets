import strutils
import sequtils
import sugar
import rdstdin

import os

import unicode


type LifeGrid = object
    grid: seq[seq[bool]]
    height, width: int

proc `[]`(grid: LifeGrid, index: int): seq[bool] =
  return grid.grid[index]

proc `[]`(grid: LifeGrid; i, j: int): bool =
  let i = (i + grid.height) mod grid.height
  let j = (j + grid.width) mod grid.width
  return grid.grid[i][j]

proc `[]=`(grid: var LifeGrid; i, j: int; value: bool) =
  let i = (i + grid.height) mod grid.height
  let j = (j + grid.width) mod grid.width
  grid.grid[i][j] = value

proc initLifeGrid(height, width: int): LifeGrid =
  result.grid = newSeq[seq[bool]](height)
  for i in 0 ..< height:
    result.grid[i] = newSeq[bool](width)
  result.height = height
  result.width = width

proc `$`(grid: LifeGrid): string =
  var rows = newSeq[string](grid.height)
  for i in 0 ..< grid.height:
    rows[i] = grid[i].map(x => "•O".toRunes[x.int]).join
  return rows.join("\n")

proc evaluate(grid: LifeGrid; i, j: int): bool =
  var aliveNeighbors = -int(grid[i, j])
  for di in -1  .. 1:
    for dj in -1 .. 1:
      aliveNeighbors += int(grid[i + di, j + dj])
  return grid[i, j] and aliveNeighbors == 2 or aliveNeighbors == 3


type Life = object
  frame, nextFrame: LifeGrid
  height, width: int

proc initLife(height, width: int): Life =
  result.frame = initLifeGrid(height, width)
  result.nextFrame = initLifeGrid(height, width)
  result.height = height
  result.width = width

proc `[]=`(life: var Life; i, j: int; value: bool) =
  life.frame[i, j] = value

proc `$`(life: Life): string = $life.frame

proc runGeneration(life: var Life) =
  for i in 0 ..< life.height:
    for j in 0 ..< life.width:
      life.nextFrame[i, j] = life.frame.evaluate(i, j)
  swap(life.frame, life.nextFrame)


proc main() =
  var life = initLife(5, 10)
  let shape = [
    ".O.",
    "..O",
    "OOO",
  ]
  for i in 0 .. 2:
    for j in 0 .. 2:
      if shape[i][j] == 'O':
        life[i + 1, j + 1] = true

  let dummyLines = repeat("\n", 57 - 5)
  while true:

    echo dummylines & $life
    #life.runGeneration()
    #sleep(300)

when is_main_module:
  main()
