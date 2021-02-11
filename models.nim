## Game models
import lists
import random


#--- Place and Direction ------------------------------------------------------
type Place = tuple[x: int, y: int]

type Command* = enum
  North, East, South, West, Quit

type Direction* = range[North .. West]

converter toPlace(direction: Direction): Place =
  case direction:
  of North: (0, -1)
  of East: (1, 0)
  of South: (0, 1)
  of West: (-1, 0)

proc `+`(a, b: Place): Place = (a.x + b.x, a.y + b.y)

proc `mod`(a, b: Place): Place = ((a.x + b.x) mod b.x, (a.y + b.y) mod b.y)

proc `||`(a, b: Direction): bool =
  (a in [North, South] and b in [North, South] or
   a in [East, West] and b in [East, West])


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

proc `[]`*(grid: Grid; p: Place): char = grid.grid[p.y][p.x]

proc `[]=`(grid: var Grid; x, y: int; c: char) = grid.grid[y][x] = c

proc `[]=`(grid: var Grid; p: Place; c: char) = grid.grid[p.y][p.x] = c

proc clear(grid: var Grid) =
  for y in 0 ..< grid.h:
    for x in 0 ..< grid.w:
      grid[x, y] = ' '


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

proc teleport(snake: var Snake; borders: Place) =
  snake.head.value = snake.head.value mod borders


#--- Game ---------------------------------------------------------------------
type Game* = object
  grid*: Grid
  snake: Snake
  direction: Direction
  food: Place

proc generateFood(game: var Game)

proc initGame*(w, h: int): Game =
  randomize()
  result.grid = newGrid(w, h)
  result.snake = initSnake()
  result.direction = East
  result.generateFood()

proc borders(game: Game): Place = (game.grid.w, game.grid.h)

proc nextHeadPlace(game: Game): Place =
  (game.snake.head.value + game.direction) mod game.borders

proc generateFood(game: var Game) =
  while true:
    block generation:
      let (w, h) = game.borders
      let food = (rand(w - 1), rand(h - 1))
      if food == game.nextHeadPlace:
        break generation
      for node in game.snake.nodes():
        if food == node.value:
          break generation
      game.food = food
      return

proc tick*(game: var Game; direction: Direction) =
  if not (direction || game.direction):
    game.direction = direction

  for node in game.snake.nodes():
    if game.nextHeadPlace == node.value:
      let (w, h) = game.borders
      game = initGame(w, h)
      return

  var grow = false
  if game.nextHeadPlace == game.food:
    grow = true
    game.generateFood()

  game.snake.move(game.direction, grow)
  game.snake.teleport(game.borders)

  game.grid.clear()
  game.grid[game.food] = '*'
  for node in game.snake.nodes():
    game.grid[node.value] = 'O'
