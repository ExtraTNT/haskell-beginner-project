-- ==================================================================
--   LEVEL 4: Puddles
-- ==================================================================
--
--   Water  ~~  is in the way. The robot can't swim, but it can fill the
--   water with a box  [] .
--
--   NEW moves:
--
--       grab       pick up the box in front of the robot
--       drop       put the box down in front of the robot
--                  (dropped into water, it fills the water up)
--
--   The robot carries the box IN FRONT of itself. So the box needs room
--   too: if the box bumps into a wall, the level is lost!
--   While carrying,  blockF s  tells you what is on the floor under the box.
--
--   NEW sensor:
--
--       holding s     what the robot carries:  Nothing  or  Just Box
--
--   You can ask two questions at once with  &&  ("and"):
--
--       | holding s == Nothing && blockF s == Box = [grab]
--
--   Start it:   cabal run level4
--   Try things: cabal repl level4   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level4 step
