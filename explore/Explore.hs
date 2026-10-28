-- | cabal run explore
--
--   Drive the robot by hand through every level and see what each move
--   and each sensor does.
module Main (main) where

import Levels (allLevels)
import Robot.Explore (explore)

main :: IO ()
main = explore allLevels
