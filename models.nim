## Game models
import lists


#--- Place and Direction ------------------------------------------------------
type Place = tuple[x: int, y: int]

type Direction = enum
  North, East, South, West

converter toPlace(direction: Direction): Place =
  case direction:
  of North: (0, -1)
  of East: (1, 0)
  of South: (0, 1)
  of West: (-1, 0)

proc `+`(a, b: Place): Place = (a.x + b.x, a.y + b.y)

#--- Grid ---------------------------------------------------------------------
type Grid* = ref object
  w*, h*: int
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

proc `[]`*(grid: Grid; x, y: int): char = grid.grid[y][x]

proc `[]=`(grid: var Grid; x, y: int; c: char) = grid.grid[y][x] = c

proc clear(grid: var Grid) =
  for y in 0 ..< grid.h:
    for x in 0 ..< grid.w:
      grid[x, y] = '.'

#--- Snake --------------------------------------------------------------------
type Snake = DoublyLinkedList[Place]

proc move(snake: var Snake, direction: Direction, grow: bool) =
  snake.prepend(snake.head.value + direction)
  if not grow:
    snake.remove(snake.tail)

proc initSnake(
  start: Place = (0, 0);
  length: int = 3;
  direction: Direction = East;
): Snake =
  result = initDoublyLinkedList[Place]()
  result.prepend(start)
  for i in 0 ..< length - 1:
    result.move(direction, grow = true)

#--- Game ---------------------------------------------------------------------
type Game* = object
  grid*: Grid
  snake: Snake

proc initGame*(w, h: int): Game =
  result.grid = newGrid(w, h)
  result.snake = initSnake()

proc tick*(game: var Game) =
  game.snake.move(South, grow = false)
  game.grid.clear()
  for node in game.snake.nodes():
    let (x, y) = node.value
    game.grid[x, y] = 'O'