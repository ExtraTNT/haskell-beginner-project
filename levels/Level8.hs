-- ==================================================================
--   LEVEL 8: The hidden button
-- ==================================================================
--
--   The robot starts in front of a sign  !! . Somewhere in the wall
--   there is a HIDDEN BUTTON. It looks like a wall, and the sensors
--   say Wall too, but you can press it to open the door.
--
--   The sign tells you where it is:
--
--       Turn right, then drive as many fields forward as there are
--       letters 'a' on the sign. The hidden button is then on your LEFT.
--
--   Pressing a real wall loses the level, so count carefully!
--
--   NEW sensor:
--
--       read s        the text on the sign in front of the robot,
--                     for example "banana"   ("" when there is no sign)
--
--   NEW Haskell:
--
--       length "hello"              is 5         (how many letters)
--       filter (== 'l') "hello"     is "ll"      (keep only the l's)
--       replicate 3 (move F)        three moves, and the 3 can be
--                                   something you computed!
--
--   The todo stack starts as  ["read sign", "go to end"] . Make the
--   whole plan while the robot still sees the sign:
--
--       step s
--         | peek s == Just "read sign" = [turn R] ++ ... ++ [pop]
--         | otherwise                  = ...
--
--   Try in  cabal repl level8 :   length (filter (== 'a') "banana")
--
--   Start it:   cabal run level8
--   Try things: cabal repl level8   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level8 step
