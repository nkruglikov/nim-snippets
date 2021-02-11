import os
import options
import models

import view/terminal


type KeyboardInterrupt = object of Exception


proc onCtrlC() {.noconv.} =
  raise newException(KeyboardInterrupt, "")


setControlCHook(onCtrlC)


proc mainLoop() =
  var game = initGame(10, 10)
  var direction = East
  initView()
  initController()

  while true:
    try:
      let command = getCommand()
      if command.isSome():
        case command.get()
        of North .. West: direction = command.get()
        of Quit: break
      game.tick(direction)
      game.grid.display()
      sleep(500)
    except KeyboardInterrupt:
      echo ""
      break

  finishView()
  finishController()


when isMainModule:
  mainLoop()
