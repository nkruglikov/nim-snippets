import os
import options
import models

import terminal/view
import terminal/controller


proc mainLoop() =
  var
    game = initGame(15, 10)
    direction = East

  initView()
  initController()
  while true:
    let command = getCommand()
    if command.isSome():
      case command.get()
      of North .. West: direction = command.get()
      of Quit: break
    game.tick(direction)
    game.grid.display()
    sleep(100)
  finishView()
  finishController()


when isMainModule:
  mainLoop()
