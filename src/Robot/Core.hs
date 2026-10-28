-- | The robot's world and the rules of the game.
module Robot.Core
  ( -- * The world
    Block (..)
  , Dir (..)
  , Heading (..)
  , Pos
  , World (..)
  , blockAt
  , nextTo
    -- * Sensors
  , Sensors (..)
  , look
  , blockF
  , blockB
  , blockL
  , blockR
  , holding
  , peek
  , position
  , facing
  , read
  , free
    -- * Moves
  , Move (..)
  , move
  , turn
  , grab
  , drop
  , press
  , push
  , pop
  , explain
    -- * Rules
  , Status (..)
  , act
    -- * Levels
  , Level (..)
  , parseMap
  ) where

import Prelude hiding (drop, read)

import Data.Char (isDigit)
import Data.List (partition)
import qualified Data.Map.Strict as Map
import qualified Data.Set as Set

------------------------------------------------------------------------------
-- The world

-- | Everything that can be on a field of the map.
data Block
  = Floor     -- ^ empty floor, the robot can drive here
  | Wall      -- ^ solid wall
  | Water     -- ^ the robot sinks, but a dropped box fills it up
  | Lava      -- ^ the robot melts
  | Box       -- ^ can be grabbed, carried and dropped
  | Switch    -- ^ press it to open (or close again!) all doors
  | Door      -- ^ a closed door, solid like a wall
  | OpenDoor  -- ^ an open door, the robot can drive through
  | Sign      -- ^ has a text on it, see 'read'
  | Exit      -- ^ the goal
  deriving (Eq, Show)

-- | Directions as seen from the robot: Forwards, Backwards, Left, Right.
data Dir = F | B | L | R
  deriving (Eq, Show)

-- | Directions on the map, like on a compass. North is up.
data Heading = North | East | South | West
  deriving (Eq, Show)

-- | (x, y): x counts columns from the left, y counts rows from the top.
type Pos = (Int, Int)

data World = World
  { grid    :: !(Map.Map Pos Block)
  , size    :: !(Int, Int)
  , robot   :: !Pos
  , heading :: !Heading
  , carried :: !(Maybe Block)
  , stack   :: ![String]
  , signs   :: !(Map.Map Pos String)  -- ^ the text on each sign
  , hidden  :: !(Set.Set Pos)         -- ^ hidden buttons: walls that work like a switch
  }

clockwise :: Heading -> Heading
clockwise North = East
clockwise East  = South
clockwise South = West
clockwise West  = North

-- | Which way on the map is @d@ for a robot facing @h@?
rotate :: Dir -> Heading -> Heading
rotate F = id
rotate R = clockwise
rotate B = clockwise . clockwise
rotate L = clockwise . clockwise . clockwise

-- | The field @n@ steps away from @p@, going towards @h@.
stepsFrom :: Heading -> Int -> Pos -> Pos
stepsFrom h n (x, y) = case h of
  North -> (x, y - n)
  East  -> (x + n, y)
  South -> (x, y + n)
  West  -> (x - n, y)

-- | Everything outside the map counts as wall.
blockAt :: World -> Pos -> Block
blockAt w p = Map.findWithDefault Wall p (grid w)

-- | The field right next to the robot, in direction @d@.
nextTo :: Dir -> World -> Pos
nextTo d w = stepsFrom (rotate d (heading w)) 1 (robot w)

------------------------------------------------------------------------------
-- Sensors

-- | What the robot's sensors measured. Read them with 'blockF', 'holding', ...
newtype Sensors = Sensors World

-- | What is @n@ fields away in direction @d@? (@look F 1@ is the same as 'blockF'.)
look :: Dir -> Int -> Sensors -> Block
look d n (Sensors w) = blockAt w (stepsFrom (rotate d (heading w)) n (robot w))

-- | The block in front of, behind, left of and right of the robot.
--   When carrying a box, 'blockF' tells what is on the floor under the box.
blockF, blockB, blockL, blockR :: Sensors -> Block
blockF = look F 1
blockB = look B 1
blockL = look L 1
blockR = look R 1

-- | What the robot carries: @Nothing@, or @Just Box@.
holding :: Sensors -> Maybe Block
holding (Sensors w) = carried w

-- | The top note of the todo stack, or @Nothing@ when it is empty.
peek :: Sensors -> Maybe String
peek (Sensors w) = case stack w of
  []      -> Nothing
  (x : _) -> Just x

-- | Where the robot is: (x, y).
position :: Sensors -> (Int, Int)
position (Sensors w) = robot w

-- | Which way the robot looks on the map.
facing :: Sensors -> Heading
facing (Sensors w) = heading w

-- | The text on the sign in front of the robot, or @""@ when there is no sign.
read :: Sensors -> String
read (Sensors w) = Map.findWithDefault "" (nextTo F w) (signs w)

-- | Can the robot drive onto this block?
free :: Block -> Bool
free b = b `elem` [Floor, OpenDoor, Exit]

-- | Blocks the robot (or a carried box) bumps into.
solid :: Block -> Bool
solid b = b `elem` [Wall, Box, Switch, Door, Sign]

------------------------------------------------------------------------------
-- Moves

data Move = Move Dir | Turn Dir | Grab | Drop | Press | Push String | Pop
  deriving Eq

-- | Moves are shown exactly the way kids write them.
instance Show Move where
  show (Move d)    = "move " ++ show d
  show (Turn d)    = "turn " ++ show d
  show Grab        = "grab"
  show Drop        = "drop"
  show Press       = "press"
  show (Push note) = "push " ++ show note
  show Pop         = "pop"

-- | Drive one field: @move F@ forwards, @move B@ backwards.
move :: Dir -> Move
move = Move

-- | Turn on the spot: @turn L@, @turn R@, or @turn B@ to turn around.
turn :: Dir -> Move
turn = Turn

-- | Pick up the box in front. It is carried in front of the robot.
grab :: Move
grab = Grab

-- | Put the carried box down in front. Dropped into water, it fills the water.
drop :: Move
drop = Drop

-- | Press the switch in front.
press :: Move
press = Press

-- | Put a note on top of the todo stack.
push :: String -> Move
push = Push

-- | Throw away the top note of the todo stack.
pop :: Move
pop = Pop

-- | What a move does, in words.
explain :: Move -> String
explain m = case m of
  Move F    -> "drive one field forwards"
  Move B    -> "drive one field backwards"
  Move _    -> "the robot can't drive sideways, it has to turn first"
  Turn F    -> "does nothing: the robot already looks forwards"
  Turn L    -> "turn left"
  Turn R    -> "turn right"
  Turn B    -> "turn around"
  Grab      -> "pick up the box in front of the robot"
  Drop      -> "put the box down in front (dropped into water, it fills it up)"
  Press     -> "press the switch in front: all doors open, or close again"
  Push note -> "put the note " ++ show note ++ " on top of the todo stack"
  Pop       -> "throw away the top note of the todo stack"

------------------------------------------------------------------------------
-- Rules

data Status = Going | Escaped | Lost String

named :: Block -> String
named b = case b of
  Floor    -> "the empty floor"
  Wall     -> "a wall"
  Water    -> "the water"
  Lava     -> "the lava"
  Box      -> "a box"
  Switch   -> "a switch"
  Door     -> "a closed door"
  OpenDoor -> "an open door"
  Sign     -> "a sign"
  Exit     -> "the exit"

-- | Do one move.
act :: Move -> World -> (World, Status)
act (Move d) w
  | d == L || d == R = (w, Lost "The robot has wheels, not legs: it can only move F or B. Turn first!")
  | ground == Exit   = (moved, Escaped)
  | solid ground     = (w, Lost ("BONK! The robot drove into " ++ named ground ++ "."))
  | ground == Water  = (moved, Lost "SPLASH! The robot drove into the water and sank.")
  | ground == Lava   = (moved, Lost "SIZZLE! The robot drove into the lava.")
  | otherwise        = fitBox "driving" moved
  where
    target = nextTo d w
    ground = blockAt w target
    moved  = w { robot = target }
act (Turn d) w = fitBox "turning" w { heading = rotate d (heading w) }
act Grab w
  | carried w /= Nothing = (w, Lost "The robot's hands are already full!")
  | ahead == Box         = (w { carried = Just Box, grid = Map.insert front Floor (grid w) }, Going)
  | otherwise            = (w, Lost ("The robot tried to grab " ++ named ahead ++ ". Only boxes can be grabbed!"))
  where
    front = nextTo F w
    ahead = blockAt w front
act Drop w = case (carried w, ahead) of
  (Nothing, _)    -> (w, Lost "The robot tried to drop something, but its hands are empty.")
  (Just b, Floor) -> (w { carried = Nothing, grid = Map.insert front b (grid w) }, Going)
  (Just _, Water) -> (w { carried = Nothing, grid = Map.insert front Floor (grid w) }, Going)
  (Just _, Lava)  -> (w { carried = Nothing }, Going)
  (Just _, other) -> (w, Lost ("The robot can't put the box down on " ++ named other ++ "."))
  where
    front = nextTo F w
    ahead = blockAt w front
act Press w
  | blockAt w front == Switch || front `Set.member` hidden w =
      (w { grid = Map.mapWithKey toggle (grid w) }, Going)
  | otherwise = (w, Lost ("The robot pressed " ++ named (blockAt w front) ++ ", but there is no switch!"))
  where
    front = nextTo F w
    toggle p b
      | p == robot w  = b -- never slam a door shut on the robot
      | b == Door     = OpenDoor
      | b == OpenDoor = Door
      | otherwise     = b
act (Push note) w = (w { stack = note : stack w }, Going)
act Pop w = (w { stack = drop1 (stack w) }, Going)
  where
    drop1 []       = []
    drop1 (_ : xs) = xs

-- | A carried box floats in front of the robot, so it needs room there too.
fitBox :: String -> World -> (World, Status)
fitBox doing w
  | carried w /= Nothing && solid ahead =
      (w, Lost ("CRASH! The box hit " ++ named ahead ++ " while the robot was " ++ doing ++ "."))
  | otherwise = (w, Going)
  where
    ahead = blockAt w (nextTo F w)

------------------------------------------------------------------------------
-- Levels

data Level = Level
  { levelName :: String
  , levelTodo :: [String]    -- ^ the notes on the todo stack at the start, top first
  , levelMaps :: [[String]]  -- ^ one step function has to solve all of them
  }

-- | Map symbols:  # wall  . floor  ~ water  % lava  o box
--                 S switch  D door  / open door  E exit
--                 h hidden button (looks like a wall)
--                 1-9 a sign, with its text in a line like  "1: hello"
--                 > < ^ v  the robot, looking that way
parseMap :: [String] -> [String] -> World
parseMap notes rows = case starts of
  [(p, h)] -> World
    { grid    = Map.fromList [ (q, tile c) | (q, c) <- fields ]
    , size    = (maximum (0 : map length mapRows), length mapRows)
    , robot   = p
    , heading = h
    , carried = Nothing
    , stack   = notes
    , signs   = Map.fromList [ (q, signText c) | (q, c) <- fields, isDigit c ]
    , hidden  = Set.fromList [ q | (q, 'h') <- fields ]
    }
  [] -> error "This map has no robot! Put one of  > < ^ v  on the map."
  _  -> error "This map has more than one robot!"
  where
    (texts, mapRows) = partition isSignText rows
    fields = [ ((x, y), c) | (y, row) <- zip [0 ..] mapRows, (x, c) <- zip [0 ..] row ]
    starts = [ (p, h) | (p, c) <- fields, Just h <- [robotFacing c] ]

    isSignText (d : ':' : _) = isDigit d
    isSignText _             = False

    signText d = case [ dropWhile (== ' ') text | (d' : ':' : text) <- texts, d' == d ] of
      (text : _) -> text
      []         -> error ("Sign " ++ [d] ++ " has no text! Add a line like  \"" ++ [d] ++ ": hello\"  to the map.")

robotFacing :: Char -> Maybe Heading
robotFacing c = lookup c [('^', North), ('>', East), ('v', South), ('<', West)]

tile :: Char -> Block
tile c = case c of
  '#' -> Wall
  '.' -> Floor
  ' ' -> Floor
  '~' -> Water
  '%' -> Lava
  'o' -> Box
  'S' -> Switch
  'D' -> Door
  '/' -> OpenDoor
  'E' -> Exit
  'h' -> Wall
  _ | isDigit c -> Sign
    | Just _ <- robotFacing c -> Floor
    | otherwise -> error ("Unknown map symbol: " ++ show c)
