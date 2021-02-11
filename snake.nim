import os
import models
import view/terminal


type KeyboardInterrupt = object of Exception


proc onCtrlC() {.noconv.} =
  raise newException(KeyboardInterrupt, "")


setControlCHook(onCtrlC)


proc mainLoop() =
  var game = initGame(10, 10)
  initView()

  while true:
    try:
      game.tick()
      game.grid.display()
      sleep(500)
    except KeyboardInterrupt:
      echo ""
      break

  finishView()


when isMainModule:
  mainLoop()
