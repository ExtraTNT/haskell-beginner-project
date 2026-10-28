-- ==================================================================
--   LEVEL 2: The long way
-- ==================================================================
--
--   This way is long. Typing  move F  again and again gets boring...
--   Haskell can help:
--
--       replicate 3 (move F)        is the same as  [move F, move F, move F]
--
--       [move F] ++ [turn L]        ++ glues two lists together:
--                                   [move F, turn L]
--
--   Together:
--
--       step s = replicate 3 (move F) ++ [turn R] ++ replicate 2 (move F)
--
--   Try it in  cabal repl level2 : type  replicate 4 (move F)  and Enter.
--
--   Start it:   cabal run level2
--   Try things: cabal repl level2   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level2 step
