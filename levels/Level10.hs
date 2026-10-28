-- ==================================================================
--   LEVEL 10: Secret message
-- ==================================================================
--
--   Lava again, and again a sign. But this time the route is hidden
--   in a sentence, like:
--
--       "Run Fast, Rex! Find Food..."
--
--   Only the CAPITAL letters F, L, R and B are the route. Everything
--   else (small letters, spaces, ! and ,) is just there to confuse you.
--
--   Use  filter  to keep only the route letters, and then  map  them
--   to moves like in level 9.
--
--       filter (== 'F') "Fun Fox"           is "FF"
--       elem 'R' "FLRB"                     is True    (is 'R' in "FLRB"?)
--       filter (\c -> elem c "FLRB") "Run Fast, Rex!"     is "RFR"
--
--   \c -> ...  is a function without a name: "take a letter c, and ..."
--
--   Start it:   cabal run level10
--   Try things: cabal repl level10   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level10 step
