-- | The explorer: drive the robot by hand, one command at a time, and see
--   what every sensor says after each move.
module Robot.Explore (explore) where

import Prelude hiding (drop, read)

import Data.Char (isSpace, toLower)
import Data.List (intercalate)
import System.IO (hFlush, isEOF, stdout)
import Text.Read (readMaybe)

import Robot.Core
import Robot.Draw

data Command
  = Do Move
  | Look Dir Int
  | Undo
  | Reset
  | Next
  | Back
  | Help
  | Quit
  | Unknown String

data Sandbox = Sandbox
  { level   :: Level
  , mapNo   :: Int
  , history :: [World]       -- ^ newest first, the start of the map last
  , done    :: [Move]        -- ^ newest first
  , ended   :: Maybe String  -- ^ set when the map is won or lost
  , message :: [String]
  }

explore :: [Level] -> IO ()
explore levels = withTerminal (chooseLevel levels "")

------------------------------------------------------------------------------
-- The level list

chooseLevel :: [Level] -> String -> IO ()
chooseLevel levels note = do
  page $
    [ "", "  " ++ paint "1" "Robot explorer", ""
    , "  Drive the robot yourself and watch what its sensors say.", "" ]
    ++ zipWith levelLine [1 :: Int ..] levels
    ++ [ "", "  h)  help: every move and sensor", "  q)  quit", "", "  " ++ note ]
  answer <- ask "Pick a level: "
  case answer of
    Nothing -> pure ()
    Just a
      | a `elem` ["q", "quit"] -> pure ()
      | a `elem` ["h", "help"] -> showHelp >> chooseLevel levels ""
      | Just k <- readMaybe a, k >= 1, k <= length levels -> do
          back <- sandbox (start (levels !! (k - 1)) 1)
          if back then chooseLevel levels "" else pure ()
      | otherwise -> chooseLevel levels ("There is no level " ++ show a ++ ".")
  where
    levelLine k l =
      "  " ++ show k ++ ")  " ++ levelName l
        ++ paint "90" ("   " ++ maps (length (levelMaps l)) ++ todoText (levelTodo l))
    maps 1 = "1 map"
    maps n = show n ++ " maps"
    todoText []    = ""
    todoText notes = ", todo stack: " ++ intercalate ", " (map show notes)

------------------------------------------------------------------------------
-- Driving around

start :: Level -> Int -> Sandbox
start l k = Sandbox
  { level   = l
  , mapNo   = k
  , history = [parseMap (levelTodo l) (levelMaps l !! (k - 1))]
  , done    = []
  , ended   = Nothing
  , message = ["Type a move, for example  move F  or  turn L ."]
  }

current :: Sandbox -> World
current sb = case history sb of
  (w : _) -> w
  []      -> error "the sandbox always has a world"

-- | Returns True to go back to the level list, False to quit.
sandbox :: Sandbox -> IO Bool
sandbox sb = do
  page (sandboxScreen sb)
  answer <- ask "> "
  case parseCommand <$> answer of
    Nothing   -> pure False
    Just Quit -> pure False
    Just Back -> pure True
    Just Help -> showHelp >> sandbox sb
    Just Reset -> sandbox (start (level sb) (mapNo sb))
    Just Next -> sandbox (start (level sb) (mapNo sb `mod` length (levelMaps (level sb)) + 1))
    Just Undo -> case (history sb, done sb) of
      (_ : older@(_ : _), _ : moves) ->
        sandbox sb { history = older, done = moves, ended = Nothing, message = ["Took the last move back."] }
      _ -> sandbox sb { message = ["Nothing to undo."] }
    Just (Look d n) ->
      sandbox sb { message = ["look " ++ show d ++ " " ++ show n ++ " s  =  " ++ value (show (look d n (Sensors (current sb))))] }
    Just (Do m) -> case ended sb of
      Just _ -> sandbox sb { message = ["This map is over. Type  undo ,  reset  or  next ."] }
      Nothing -> sandbox (perform m sb)
    Just (Unknown "") -> sandbox sb
    Just (Unknown s) -> sandbox sb { message = [paint "1;93" ("I don't know " ++ show s ++ ". Type  help  to see all commands.")] }

perform :: Move -> Sandbox -> Sandbox
perform m sb = sb
  { history = w : history sb
  , done    = m : done sb
  , ended   = case status of
      Going    -> Nothing
      Escaped  -> Just "won"
      Lost why -> Just why
  , message = case status of
      Going    -> [value (show m) ++ "  " ++ explain m]
      Escaped  -> [paint "1;92" "You made it! The robot reached the exit.", "Type  next  for the next map, or  levels ."]
      Lost why -> [paint "1;91" why, "Type  undo  to take that move back."]
  }
  where
    (w, status) = act m (current sb)

sandboxScreen :: Sandbox -> [String]
sandboxScreen sb =
  screen (level sb) (mapNo sb, length (levelMaps (level sb))) w $
    [ "What the sensors say:" ]
    ++ map ("  " ++)
      [ sensor "blockF s" (show (blockF s)) ++ sensor "free (blockF s)" (show (free (blockF s)))
      , sensor "blockL s" (show (blockL s)) ++ sensor "free (blockL s)" (show (free (blockL s)))
      , sensor "blockR s" (show (blockR s)) ++ sensor "free (blockR s)" (show (free (blockR s)))
      , sensor "blockB s" (show (blockB s)) ++ sensor "free (blockB s)" (show (free (blockB s)))
      , sensor "holding s" (show (holding s))
      , sensor "peek s" (show (peek s))
      , sensor "position s" (show (position s))
      , sensor "facing s" (show (facing s))
      , sensor "read s" (show (read s))
      ]
    ++ [ "", "todo stack: " ++ stackInfo (stack w)
       , "your moves: [" ++ intercalate ", " (map show (reverse (done sb))) ++ "]"
       , "" ]
    ++ message sb
    ++ [ "", paint "90" "Commands: a move,  look F 2 ,  undo ,  reset ,  next ,  levels ,  help ,  q" ]
  where
    w = current sb
    s = Sensors w
    sensor name v = padTo 16 name ++ "= " ++ padTo 12 (value v) ++ "  "

------------------------------------------------------------------------------
-- Help

showHelp :: IO ()
showHelp = do
  page $
    [ "", "  " ++ paint "1" "Moves", "" ]
    ++ map (\m -> "    " ++ padTo 16 (value (show m)) ++ explain m)
         [move F, move B, turn L, turn R, turn B, grab, drop, press, push "note", pop]
    ++ [ "", "  " ++ paint "1" "Sensors", "" ]
    ++ map (\(name, what) -> "    " ++ padTo 16 (value name) ++ what)
         [ ("blockF s", "the block in front of the robot")
         , ("blockL s", "the block on its left")
         , ("blockR s", "the block on its right")
         , ("blockB s", "the block behind it")
         , ("look F 2 s", "the block 2 fields in front (any direction, any distance)")
         , ("holding s", "what the robot carries: Nothing or Just Box")
         , ("peek s", "the top note of the todo stack: Nothing or Just \"...\"")
         , ("position s", "where the robot is: (x, y), counted from the top left, starting at 0")
         , ("facing s", "North, East, South or West (North is up)")
         , ("read s", "the text on the sign in front, or \"\" when there is no sign")
         , ("free b", "True if the robot can drive onto block b: Floor, OpenDoor or Exit")
         ]
    ++ [ "", "  Blocks:  Floor  Wall  Water  Lava  Box  Switch  Door  OpenDoor  Sign  Exit"
       , "", "  " ++ paint "1" "Explorer commands", "" ]
    ++ map (\(name, what) -> "    " ++ padTo 16 (value name) ++ what)
         [ ("look F 2", "ask what is 2 fields in front")
         , ("undo", "take the last move back")
         , ("reset", "start this map again")
         , ("next", "go to the next map of this level")
         , ("levels", "back to the list of levels")
         , ("q", "quit")
         ]
    ++ [ "" ]
  _ <- ask "Press Enter to go back."
  pure ()

------------------------------------------------------------------------------
-- Reading commands

ask :: String -> IO (Maybe String)
ask question = do
  putStr ("  " ++ question)
  hFlush stdout
  eof <- isEOF
  if eof then pure Nothing else Just . trim <$> getLine
  where
    trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace

parseCommand :: String -> Command
parseCommand line = case words line of
  []         -> Unknown ""
  (c : args) -> command (map toLower c) args
  where
    command "move" [d] | Just dir <- direction d = Do (move dir)
    command "turn" [d] | Just dir <- direction d = Do (turn dir)
    command "grab" []   = Do grab
    command "drop" []   = Do drop
    command "press" []  = Do press
    command "pop" []    = Do pop
    command "push" note@(_ : _) = Do (push (unquote (unwords note)))
    command "look" [d] | Just dir <- direction d = Look dir 1
    command "look" [d, n] | Just dir <- direction d, Just k <- readMaybe n = Look dir k
    command "undo" []   = Undo
    command "reset" []  = Reset
    command "next" []   = Next
    command "levels" [] = Back
    command "help" []   = Help
    command "h" []      = Help
    command "q" []      = Quit
    command "quit" []   = Quit
    command _ _         = Unknown line

    direction d = lookup (map toLower d) [("f", F), ("b", B), ("l", L), ("r", R)]

    unquote ('"' : rest) | not (null rest), last rest == '"' = init rest
    unquote s = s

------------------------------------------------------------------------------
-- Helpers

value :: String -> String
value = paint "1;96"

-- | Pad to a width, ignoring the invisible colour codes.
padTo :: Int -> String -> String
padTo n s = s ++ replicate (n - visible s) ' '
  where
    visible ('\ESC' : rest) = case dropWhile (/= 'm') rest of
      (_ : after) -> visible after
      []          -> 0
    visible (_ : rest) = 1 + visible rest
    visible []         = 0
