import os
import terminal
import lists

type KeyboardInterrupt = object of Exception

proc onCtrlC() {.noconv.} =
  raise newException(KeyboardInterrupt, "")

setControlCHook(onCtrlC)


type Grid = ref object
  w, h: int
  grid: seq[seq[char]]

proc newGrid(w, h: int): Grid =
  new(result)
  result.w = w
  result.h = h
  for y in 0 ..< h:
    var row: seq[char]
    for x in 0 ..< w:
      row.add(' ')
    result.grid.add(row)


proc `[]`(grid: Grid; x, y: int): char = grid.grid[y][x]
proc `[]=`(grid: var Grid; x, y: int; c: char) = grid.grid[y][x] = c


template writeAt(text: untyped; x, y: int) =
  setCursorPos(x, y)
  stdout.write(text)


proc display(grid: Grid) =
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

proc clear(grid: var Grid) =
  for y in 0 ..< grid.h:
    for x in 0 ..< grid.w:
      grid[x, y] = '.'


type Place = tuple[x: int, y: int]

type Direction = enum
  North, East, South, West

type Snake = DoublyLinkedList[Place]

proc move(snake: var Snake, direction: Direction, grow: bool)

proc initSnake(
  start: Place = (0, 0);
  length: int = 3;
  direction: Direction = East;
): Snake =
  result = initDoublyLinkedList[Place]()
  result.prepend(start)
  for i in 0 ..< length - 1:
    result.move(direction, grow = true)


converter toPlace(direction: Direction): Place =
  case direction:
  of North: (0, -1)
  of East: (1, 0)
  of South: (0, 1)
  of West: (-1, 0)

proc `+`(a, b: Place): Place = (a.x + b.x, a.y + b.y)

proc move(snake: var Snake, direction: Direction, grow: bool) =
  snake.prepend(snake.head.value + direction)
  if not grow:
    snake.remove(snake.tail)

type Game = object
  grid: Grid
  snake: Snake


proc tick(game: var Game) =
  game.grid.clear()
  for node in game.snake.nodes():
    let (x, y) = node.value
    game.grid[x, y] = 'O'



proc initGame(grid: Grid): Game =
  result.grid = grid
  result.snake = initSnake()

var grid = newGrid(10, 10)
var game = initGame(grid)


hideCursor()
eraseScreen()

while true:
  try:
    game.tick()
    grid.display()
    game.snake.move(South, grow = false)
    sleep(1000)
  except KeyboardInterrupt:
    echo ""
    break
showCursor()
