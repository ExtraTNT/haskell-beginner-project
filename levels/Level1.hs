-- ==================================================================
--   LEVEL 1: First steps
-- ==================================================================
--
--   Drive the robot  @>  to the exit  EX .
--
--   Your job is to write the function  step . It gives back a LIST of
--   moves, and the robot does them one after another:
--
--       move F      drive one field forwards
--       move B      drive one field backwards
--       turn L      turn left
--       turn R      turn right
--       turn B      turn around
--
--   A list is written in square brackets, with commas in between:
--
--       step s = [move F, turn L, move F]
--
--   Careful: driving into a wall or into lava loses the level!
--   If the robot drives in circles forever, press Ctrl+C to stop it.
--
--   Start it:   cabal run level1
--
--   Or try things out in the repl:
--       cabal repl level1     start the repl with this file
--       main                  play
--       :r                    after changing the file: reload it
--       playSlow level1 step  play in slow motion
--
--   Not sure what a move does? Try it by hand:  cabal run explore
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level1 step
