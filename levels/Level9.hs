-- ==================================================================
--   LEVEL 9: Follow the sign
-- ==================================================================
--
--   A room full of lava, and the exit is somewhere in the middle.
--   Following the walls won't get you there: the robot drives around
--   in circles. But the sign knows the way!
--
--   The sign holds a route, one letter for each move:
--
--       F  move forwards
--       L  turn left
--       R  turn right
--       B  turn around
--
--   For example "FFRF" means  [move F, move F, turn R, move F] .
--
--   NEW Haskell: map. It does something with EVERY element of a list.
--   A String is a list of letters (Char), so this works:
--
--       map toMove "FFRF"
--
--   You only have to write  toMove , one line for each letter:
--
--       toMove :: Char -> Move
--       toMove 'F' = move F
--       toMove 'L' = ...
--
--   Start it:   cabal run level9
--   Try things: cabal repl level9   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level9 step
