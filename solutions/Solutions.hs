-- | Example solutions, for the teacher.
--
--   cabal run solutions              watch every solution, one after another
--   cabal run solutions -- 4         watch the solution of level 4
--   cabal run solutions -- 600       watch all, 600 ms between moves
--   cabal run solutions -- 4 600     both (the order doesn't matter)
--   cabal run solutions -- check     check quickly that every level is solved
--
--   A number up to the number of levels is a level, a bigger one is a delay.
module Main (main) where

import Prelude hiding (drop, read)

import Control.Monad (forM_)
import Data.List (partition)
import Data.Maybe (fromMaybe, listToMaybe)
import System.Environment (getArgs)
import System.Exit (exitFailure)
import Text.Read (readMaybe)

import Levels
import Robot

-- Level 1: just write down the moves.
step1 :: Sensors -> [Move]
step1 s = [move F, move F, move F, move F, turn L, move F, move F]

-- Level 2: the same, but shorter with replicate and ++.
step2 :: Sensors -> [Move]
step2 s = replicate 7 (move F) ++ [turn R] ++ replicate 3 (move F) ++ [turn L] ++ replicate 6 (move F)

-- Level 3: decide one move at a time. step is asked again after each one.
step3 :: Sensors -> [Move]
step3 s
  | free (blockF s) = [move F]
  | free (blockL s) = [turn L]
  | free (blockR s) = [turn R]
  | otherwise       = [turn B]

-- Level 4: grab a box, carry it to the water, drop it in.
step4 :: Sensors -> [Move]
step4 s
  | holding s == Nothing && blockF s == Box = [grab]
  | holding s /= Nothing && blockF s == Water = [drop]
  | otherwise = [move F]

-- Level 5: look left and right for switches. Move on after pressing,
-- otherwise the next step sees the switch again and presses it again.
step5 :: Sensors -> [Move]
step5 s
  | blockL s == Switch = [turn L, press, turn R, move F]
  | blockR s == Switch = [turn R, press, turn L, move F]
  | otherwise          = [move F]

-- Level 6: the robot drives past the switch twice. After pressing it pops
-- "press button", so the second time the top note is "go to end".
step6 :: Sensors -> [Move]
step6 s
  | peek s == Just "press button" = pressButton s
  | otherwise = step3 s

pressButton :: Sensors -> [Move]
pressButton s
  | blockL s == Switch = [turn L, press, turn R, pop]
  | blockR s == Switch = [turn R, press, turn L, pop]
  | otherwise = step3 s

-- Level 7: one helper function per task on the todo stack.
step7 :: Sensors -> [Move]
step7 s
  | peek s == Just "cross bridge" = crossBridge s
  | peek s == Just "press button" = pressButton s
  | otherwise = step3 s

crossBridge :: Sensors -> [Move]
crossBridge s
  | holding s == Nothing && blockF s == Box = [grab]
  | holding s /= Nothing && blockF s == Water = [drop, pop]
  | otherwise = [move F]

-- Level 8: count the a's on the sign, drive that far, press the hidden button.
-- The whole plan is made in one step, while the robot still sees the sign.
step8 :: Sensors -> [Move]
step8 s
  | peek s == Just "read sign" = findButton s
  | otherwise = step3 s

findButton :: Sensors -> [Move]
findButton s = [turn R] ++ replicate (count 'a' (read s)) (move F) ++ [turn L, press, turn R, pop]

count :: Char -> String -> Int
count c text = length (filter (== c) text)

-- Level 9: the sign is the route. Turn every letter into a move.
step9 :: Sensors -> [Move]
step9 s = map letter (read s)

letter :: Char -> Move
letter 'L' = turn L
letter 'R' = turn R
letter 'B' = turn B
letter _   = move F

-- Level 10: the route is the capital letters F, L, R and B in the sentence.
step10 :: Sensors -> [Move]
step10 s = map letter (filter (`elem` "FLRB") (read s))

-- Level 11: remember the first sign on the stack, turn around, read the
-- second one, and drive both halves of the route.
step11 :: Sensors -> [Move]
step11 s
  | peek s == Nothing = [push (read s), turn B]
  | otherwise         = map letter (firstHalf s ++ read s)

firstHalf :: Sensors -> String
firstHalf s = case peek s of
  Just text -> text
  Nothing   -> ""

-- Level 12: one task after the other, reusing the earlier solutions.
step12 :: Sensors -> [Move]
step12 s
  | peek s == Just "cross bridge" = crossBridge s
  | peek s == Just "find button" && blockF s == Sign = findButton s
  | peek s == Just "follow route" && blockF s == Sign = step10 s
  | otherwise = step3 s

solutions :: [(Level, Sensors -> [Move])]
solutions = zip allLevels
  [step1, step2, step3, step4, step5, step6, step7, step8, step9, step10, step11, step12]

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["check"] -> do
      forM_ solutions $ \(level, step) ->
        putStrLn ((if solves step level then "  ok    " else "  FAIL  ") ++ levelName level)
      if all (\(level, step) -> solves step level) solutions
        then putStrLn "All levels solved."
        else exitFailure
    _ -> case mapM readMaybe args >>= options of
      Just (chosen, ms) -> forM_ chosen (uncurry (playWith ms))
      Nothing -> do
        putStrLn (unlines
          [ "Usage: cabal run solutions -- [LEVEL] [DELAY]"
          , "       cabal run solutions -- check"
          , ""
          , "  LEVEL  1 ... " ++ show maxLevel ++ ": watch only this level (default: all)"
          , "  DELAY  more than " ++ show maxLevel ++ ": milliseconds between moves (default: "
              ++ show defaultDelay ++ ")"
          , ""
          , "  Both are numbers, in any order: a number up to " ++ show maxLevel
              ++ " is a level, a bigger one is a delay."
          , "  Example:  cabal run solutions -- 4 600"
          ])
        exitFailure

maxLevel :: Int
maxLevel = length solutions

defaultDelay :: Int
defaultDelay = 250

-- | Up to two numbers: one up to 'maxLevel' picks the level, a bigger one is
--   the delay in milliseconds. Nothing if they don't fit that.
options :: [Int] -> Maybe ([(Level, Sensors -> [Move])], Int)
options ns
  | length ns > 2 || any (< 1) ns || length levels > 1 || length delays > 1 = Nothing
  | otherwise = Just (chosen, fromMaybe defaultDelay (listToMaybe delays))
  where
    (levels, delays) = partition (<= maxLevel) ns
    chosen = case levels of
      [k] -> [solutions !! (k - 1)]
      _   -> solutions
