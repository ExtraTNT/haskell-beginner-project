{-# LANGUAGE CPP #-}

-- | Drawing the world in the terminal, with ANSI colour codes.
module Robot.Draw
  ( paint
  , screen
  , stackInfo
  , worldInfo
  , page
  , redraw
  , withTerminal
  ) where

import Control.Exception (finally)
import Data.List (intercalate)
import System.IO (BufferMode (..), hFlush, hGetBuffering, hSetBuffering, stdout)

import Robot.Core

#if defined(mingw32_HOST_OS)
import Control.Monad (when)
import Data.Bits ((.|.))
import Data.Word (Word32)
import Foreign.C.Types (CInt (..))
import Foreign.Marshal.Alloc (alloca)
import Foreign.Ptr (Ptr)
import qualified Foreign.Storable as Storable
#endif

paint :: String -> String -> String
paint code s = "\ESC[" ++ code ++ "m" ++ s ++ "\ESC[0m"

glyph :: Block -> String
glyph b = case b of
  Floor    -> paint "90" " ."
  Wall     -> paint "37;100" "##"
  Water    -> paint "96;44" "~~"
  Lava     -> paint "93;41" "^^"
  Box      -> paint "30;43" "[]"
  Switch   -> paint "1;97;45" "()"
  Door     -> paint "97;45" "||"
  OpenDoor -> paint "35" "__"
  Sign     -> paint "1;30;47" "!!"
  Exit     -> paint "1;30;42" "EX"

robotGlyph :: Heading -> String
robotGlyph h = paint "1;96" $ case h of
  North -> "@^"
  East  -> "@>"
  South -> "@v"
  West  -> "<@"

carriedGlyph :: String
carriedGlyph = paint "1;30;103" "[]"

legend :: [String]
legend = map (intercalate "   ")
  [ [ robotGlyph East ++ " robot", glyph Wall ++ " wall", glyph Water ++ " water"
    , glyph Lava ++ " lava", glyph Box ++ " box" ]
  , [ glyph Switch ++ " switch", glyph Door ++ " door", glyph OpenDoor ++ " open door"
    , glyph Sign ++ " sign", glyph Exit ++ " exit" ] ]

drawWorld :: World -> [String]
drawWorld w = [ concatMap (\x -> cell (x, y)) [0 .. width - 1] | y <- [0 .. height - 1] ]
  where
    (width, height) = size w
    boxAt = nextTo F w <$ carried w
    cell p
      | p == robot w    = robotGlyph (heading w)
      | Just p == boxAt = carriedGlyph
      | otherwise       = glyph (blockAt w p)

-- | The todo stack, top note first.
stackInfo :: [String] -> String
stackInfo []    = "(empty)"
stackInfo notes = "top -> " ++ intercalate ", " (map show notes)

worldInfo :: World -> [String]
worldInfo w =
  [ "holding:  " ++ maybe "nothing" show (carried w) ++ "      todo stack: " ++ stackInfo (stack w)
  , "position: " ++ show (robot w) ++ "  facing " ++ show (heading w)
  ]

-- | A whole screen: the level title, the map, some lines of info, the legend.
screen :: Level -> (Int, Int) -> World -> [String] -> [String]
screen level (k, n) w info =
  [ "", "  " ++ paint "1" (levelName level) ++ paint "90" ("     map " ++ show k ++ " of " ++ show n), "" ]
  ++ map ("  " ++) (drawWorld w)
  ++ [""]
  ++ map ("  " ++) info
  ++ [""] ++ map ("  " ++) legend ++ [""]

-- | Draw over the previous screen without clearing it first, so animations don't flicker.
redraw :: [String] -> IO ()
redraw ls = do
  putStr ("\ESC[H" ++ concatMap (++ "\ESC[K\n") ls ++ "\ESC[J")
  hFlush stdout

-- | Clear the terminal and show a new page.
page :: [String] -> IO ()
page ls = do
  putStr ("\ESC[2J\ESC[H" ++ unlines ls)
  hFlush stdout

-- | Prepare the terminal for drawing, and put it back afterwards.
withTerminal :: IO a -> IO a
withTerminal action = do
  enableAnsi
  buffering <- hGetBuffering stdout
  hSetBuffering stdout (BlockBuffering Nothing)
  action `finally` (hFlush stdout >> hSetBuffering stdout buffering)

#if defined(mingw32_HOST_OS)
foreign import ccall unsafe "GetStdHandle"
  c_GetStdHandle :: Word32 -> IO (Ptr ())
foreign import ccall unsafe "GetConsoleMode"
  c_GetConsoleMode :: Ptr () -> Ptr Word32 -> IO CInt
foreign import ccall unsafe "SetConsoleMode"
  c_SetConsoleMode :: Ptr () -> Word32 -> IO CInt

-- | Old Windows consoles only understand colour codes after being asked to.
enableAnsi :: IO ()
enableAnsi = do
  console <- c_GetStdHandle 0xFFFFFFF5 -- STD_OUTPUT_HANDLE
  alloca $ \modePtr -> do
    ok <- c_GetConsoleMode console modePtr
    when (ok /= 0) $ do
      mode <- Storable.peek modePtr
      _ <- c_SetConsoleMode console (mode .|. 0x4) -- ENABLE_VIRTUAL_TERMINAL_PROCESSING
      pure ()
#else
-- | Linux and macOS terminals understand colour codes already.
enableAnsi :: IO ()
enableAnsi = pure ()
#endif
