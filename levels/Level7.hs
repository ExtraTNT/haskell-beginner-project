-- ==================================================================
--   LEVEL 7: The big escape
-- ==================================================================
--
--   Boxes, water, tunnels, switches and doors, all together.
--   The todo stack starts with three tasks:
--
--       ["cross bridge", "press button", "go to end"]
--
--   Write one function for each task, and let step choose the one
--   for the task on top:
--
--       step :: Sensors -> [Move]
--       step s
--         | peek s == Just "cross bridge" = crossBridge s
--         | peek s == Just "press button" = pressButton s
--         | otherwise                     = goToEnd s
--
--       crossBridge :: Sensors -> [Move]
--       crossBridge s
--         | ...
--
--   When a task is done,  pop  it, and the next task comes up.
--   A list of moves can end with pop, for example:  [drop, pop]
--
--   Start it:   cabal run level7
--   Try things: cabal repl level7   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level7 step
