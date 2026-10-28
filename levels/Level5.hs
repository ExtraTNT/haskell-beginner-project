-- ==================================================================
--   LEVEL 5: Doors
-- ==================================================================
--
--   A closed door  ||  blocks the way. Somewhere next to the path is a
--   switch  () . Press it, and all doors open.
--
--   NEW move:
--
--       press      press the switch in front of the robot
--
--   The robot can only press a switch that is IN FRONT of it, so it has
--   to turn towards the switch first. Pressing when there is no switch
--   in front loses the level!
--
--   Watch out: pressing a switch again closes the doors again.
--
--   Start it:   cabal run level5
--   Try things: cabal repl level5   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level5 step
