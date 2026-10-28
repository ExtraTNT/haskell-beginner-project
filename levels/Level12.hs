-- ==================================================================
--   LEVEL 12: The grand finale
-- ==================================================================
--
--   Everything at once! The todo stack starts with three tasks:
--
--       ["cross bridge", "find button", "follow route"]
--
--   cross bridge   Grab the box and drop it into the water (level 4).
--
--   find button    Follow the tunnel to the first sign (level 3).
--                  Turn right and drive as many fields as there are
--                  letters 'a' on the sign. The hidden button is on
--                  your LEFT, and it opens the door (level 8).
--
--   follow route   Follow the tunnel through the door to the second
--                  sign. The route through the lava is hidden in its
--                  capital letters F, L, R and B (level 10).
--
--   Don't forget to  pop  each task when it is done!
--
--   Tip: copy your helper functions from the earlier levels and let
--   step choose between them:
--
--       step s
--         | peek s == Just "cross bridge"                     = crossBridge s
--         | peek s == Just "find button" && blockF s == Sign  = findButton s
--         | ...
--         | otherwise                                         = tunnel s
--
--   Start it:   cabal run level12
--   Try things: cabal repl level12   (then  main ,  :r  after changes)
-- ==================================================================

import Prelude hiding (drop, read)
import Robot
import Levels

step :: Sensors -> [Move]
step s = [move F]

main :: IO ()
main = play level12 step
