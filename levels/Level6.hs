-- ==================================================================
--   LEVEL 6: Don't press twice!
-- ==================================================================
--
--   This time the robot drives past the switch TWICE. If it presses
--   both times, the door closes again. The robot has to know that the
--   button is already done.
--
--   NEW: the todo stack, a pile of notes with the robot's tasks. You
--   can only see the top note. In this level the pile starts like this
--   (top note first):
--
--       ["press button", "go to end"]
--
--   Sensors:
--       peek s        the top note:  Just "press button"
--                     (or  Nothing  when the stack is empty)
--
--   Moves:
--       pop           this task is done: throw the top note away
--       push "note"   put a new note on top
--
--   So step can ask which task is on top, and do something different
--   for each one:
--
--       step s
--         | peek s == Just "press button" = ...
--         | otherwise                     = ...
--
--   Don't forget to  pop  when the button is pressed! Then the top note
--   is "go to end", and the robot drives past the switch.
--
--   Tip: the tunnel solution from level 3 is useful here again.
--
--   Start it:   cabal run level6
--   Try things: cabal repl level6   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level6 step
