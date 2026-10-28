-- ==================================================================
--   LEVEL 11: Torn map
-- ==================================================================
--
--   The route through the lava was torn in two! The robot stands
--   between two signs: sign 1 is in front of it, sign 2 is behind it.
--
--       sign 1 has the FIRST half of the route
--       sign 2 has the SECOND half
--
--   The route starts when the robot looks at sign 2. So: read sign 1,
--   turn around, read sign 2, then drive the first half and then the
--   second half.
--
--   The problem:  read s  only reads the sign in front. After turning
--   around, sign 1 is behind the robot and step can't see it any more.
--   So the robot has to WRITE IT DOWN on the todo stack first:
--
--       push (read s)       put the text of the sign on the stack
--
--   The stack starts empty, so  peek s == Nothing  means "I haven't
--   read sign 1 yet".
--
--   NEW Haskell: getting the text back out of  Just "..."  with case:
--
--       firstHalf :: Sensors -> String
--       firstHalf s = case peek s of
--         Just text -> text
--         Nothing   -> ""
--
--   And two texts can be glued together with ++ , just like lists:
--
--       "LFF" ++ "RF"       is "LFFRF"
--
--   Tip: your toMove function from level 9 is useful again.
--
--   Start it:   cabal run level11
--   Try things: cabal repl level11   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level11 step
