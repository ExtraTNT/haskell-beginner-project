-- | Running a step function on a level, with or without animation.
module Robot.Play
  ( play
  , playSlow
  , playWith
  , check
  , solves
  ) where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, displayException, evaluate, try)
import Control.Monad (when)
import Data.List (intercalate)
import System.IO (hFlush, stdout)
import System.Timeout (timeout)

import Robot.Core
import Robot.Draw

type Brain = Sensors -> [Move]

data Frame = Frame
  { frameMove  :: Move    -- ^ what the robot just did
  , frameLater :: [Move]  -- ^ the rest of the current plan
  , frameWorld :: World   -- ^ the world after the move
  , frameCount :: Int     -- ^ moves done so far
  }

data Result = Won Int | Failed String

-- | Everything that happens on one map, lazily: frame after frame, then the end.
data Trace = Step Frame Trace | End World Result

-- | How many moves 'check' and 'solves' allow before giving up.
checkLimit :: Int
checkLimit = 1000

-- | With a @limit@, stop after that many moves, so checking a level always ends.
simulate :: Maybe Int -> Brain -> World -> Trace
simulate limit brain = think 0
  where
    think n w = case brain (Sensors w) of
      []   -> End w (Failed "step gave back an empty list, so the robot doesn't know what to do!")
      plan -> run n w plan
    run n w [] = think n w
    run n w (m : later)
      | maybe False (n >=) limit =
          End w (Failed ("Stopped after " ++ show n ++ " moves: the robot seems to be going round in circles."))
      | otherwise = case act m w of
          (w', status) -> w' `seq` Step (Frame m later w' (n + 1)) (case status of
            Going    -> run (n + 1) w' later
            Escaped  -> End w' (Won (n + 1))
            Lost why -> End w' (Failed why))

showPlan :: [Move] -> String
showPlan ms = case splitAt 6 ms of
  ([], _)       -> "[]   (used up: step will be asked again)"
  (first, rest) -> "[" ++ intercalate ", " (map show first) ++ (if null rest then "]" else ", ...]")

frameInfo :: Frame -> [String]
frameInfo fr =
  [ "move " ++ show (frameCount fr) ++ ":  " ++ paint "1;96" (show (frameMove fr))
  , "next:     " ++ showPlan (frameLater fr)
  ] ++ worldInfo (frameWorld fr)

resultInfo :: World -> Result -> [String]
resultInfo w result = msg : "" : worldInfo w
  where
    msg = case result of
      Won n      -> paint "1;92" ("You made it! The robot reached the exit in " ++ show n ++ " moves.")
      Failed why -> paint "1;91" why

data Mode = Animated Int | Quiet

-- | Watch the robot run your step function.
play :: Level -> (Sensors -> [Move]) -> IO ()
play = playWith 250

-- | Like 'play', but slow enough to follow every single move.
playSlow :: Level -> (Sensors -> [Move]) -> IO ()
playSlow = playWith 800

-- | Like 'play', with the pause between moves in milliseconds.
playWith :: Int -> Level -> (Sensors -> [Move]) -> IO ()
playWith ms = runLevel (Animated ms)

-- | No animation, just tell whether the step function solves the level.
check :: Level -> (Sensors -> [Move]) -> IO ()
check = runLevel Quiet

-- | Does this step function solve every map of the level? (For testing.)
solves :: (Sensors -> [Move]) -> Level -> Bool
solves brain level = all (won . simulate (Just checkLimit) brain . parseMap (levelTodo level)) (levelMaps level)
  where
    won (Step _ next)   = won next
    won (End _ (Won _)) = True
    won (End _ _)       = False

runLevel :: Mode -> Level -> Brain -> IO ()
runLevel mode level brain = withTerminal $ do
  let worlds = map (parseMap (levelTodo level)) (levelMaps level)
  solved <- allM [ runMap mode level (k, length worlds) brain w | (k, w) <- zip [1 ..] worlds ]
  putStrLn $ if solved
    then paint "1;92" ("  *** LEVEL COMPLETE! " ++ levelName level ++ " ***")
    else paint "1;93" "  Not yet... change your step function and try again!"
  where
    allM []       = pure True
    allM (a : as) = a >>= \ok -> if ok then allM as else pure False

runMap :: Mode -> Level -> (Int, Int) -> Brain -> World -> IO Bool
runMap mode level num brain start = do
  when animated (putStr "\ESC[2J")
  go start (simulate limit brain start)
  where
    (animated, limit) = case mode of
      Animated _ -> (True, Nothing) -- the kids watch, and can stop it with Ctrl+C
      Quiet      -> (False, Just checkLimit)

    go lastWorld trace = do
      next <- safely (evaluate trace)
      case next of
        Left err -> finish lastWorld (Failed err)
        Right (End w result) -> finish w result
        Right (Step fr later) -> do
          shown <- display fr
          case shown of
            Left err -> finish lastWorld (Failed err)
            Right () -> go (frameWorld fr) later

    display fr = case mode of
      Quiet -> pure (Right ())
      Animated ms -> do
        rendered <- safely (evaluate (forced (screen level num (frameWorld fr) (frameInfo fr))))
        traverse (\ls -> redraw ls >> threadDelay (ms * 1000)) rendered

    finish w result = do
      rendered <- safely (evaluate (forced (screen level num w (resultInfo w result))))
      let ls = either (\err -> ["", "  " ++ paint "1;91" err, ""]) id rendered
      case (mode, result) of
        (Quiet, Won n) -> putStrLn ("  map " ++ show (fst num) ++ " of " ++ show (snd num) ++ ": solved in " ++ show n ++ " moves")
        (Quiet, _)     -> putStr (unlines ls)
        (Animated _, _) -> redraw ls
      hFlush stdout
      case result of
        Won _ -> do
          when (animated && fst num < snd num) (threadDelay 1500000)
          pure True
        Failed _ -> pure False

-- | Fully evaluate a screen, so crashes in the kid's code show up here.
forced :: [String] -> [String]
forced ls = sum (map length ls) `seq` ls

-- | Run something that depends on the kid's code, catching crashes and endless thinking.
safely :: IO a -> IO (Either String a)
safely action = do
  r <- try (timeout 3000000 action)
  pure $ case r of
    Left e         -> Left ("Your step function crashed: " ++ firstLine (displayException (e :: SomeException)))
    Right Nothing  -> Left "Your step function thought for more than 3 seconds without deciding."
    Right (Just x) -> Right x
  where
    firstLine = takeWhile (/= '\n')
