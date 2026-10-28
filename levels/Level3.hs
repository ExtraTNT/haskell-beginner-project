-- ==================================================================
--   LEVEL 3: Three tunnels
-- ==================================================================
--
--   This level has THREE different tunnels, and ONE step function has
--   to get through all of them. A fixed list of moves won't work any
--   more: the robot has to LOOK where it is going.
--
--   NEW: sensors. The  s  in  step s  holds what the robot sees:
--
--       blockF s     what is in front of the robot?
--       blockL s     ...on its left?
--       blockR s     ...on its right?
--       blockB s     ...behind it?
--
--   A sensor answers with one of these blocks:
--
--       Floor  Wall  Water  Lava  Box  Switch  Door  OpenDoor  Exit
--
--   NEW: step is called AGAIN when its list of moves is used up, with
--   fresh sensor values. So step can give back just ONE move and then
--   decide again.
--
--   NEW: guards. The robot does the first line whose question is True:
--
--       step s
--         | blockF s == Floor = [move F]
--         | otherwise         = [turn L]
--
--   Tip:  free b  is True when the robot can drive onto b
--         (Floor, OpenDoor or Exit). For example:  free (blockL s)
--
--   Start it:   cabal run level3
--   Try things: cabal repl level3   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level3 step
