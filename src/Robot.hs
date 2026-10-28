-- | The robot game: everything a level file needs.
--
--   Kids don't need to read the engine. Everything they need is explained
--   at the top of each levels/LevelN.hs and in CHEATSHEET.md.
--
--   How a game works:
--
--     1. The robot measures its surroundings ('Sensors').
--     2. The kid's @step@ function turns the sensors into a list of moves.
--     3. The moves are done one after another. Walking into a wall, into
--        water or lava, or pressing a switch that isn't there loses the map.
--     4. When the list is used up, @step@ is asked again with fresh sensors.
--     5. Reaching the exit wins the map.
--
--   The engine lives in Robot.Core (world and rules), Robot.Draw (terminal
--   output), Robot.Play (running step functions) and Robot.Explore (the
--   explorer).
module Robot
  ( -- * What the robot sees
    Block (..)
  , Dir (..)
  , Heading (..)
  , Sensors
  , blockF
  , blockB
  , blockL
  , blockR
  , look
  , holding
  , peek
  , position
  , facing
  , read
  , free
    -- * What the robot does
  , Move
  , move
  , turn
  , grab
  , drop
  , press
  , push
  , pop
    -- * Levels and playing
  , Level (..)
  , play
  , playSlow
  , playWith
  , check
  , solves
  ) where

import Prelude hiding (drop, read)

import Robot.Core
import Robot.Play
