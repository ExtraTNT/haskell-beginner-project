-- | All the levels.
--
--   A level can have several maps. ONE step function has to solve all of
--   them, so writing down a fixed list of moves stops working and the robot
--   has to use its sensors.
--
--   Map symbols:
--
--     #  wall          .  floor         ~  water        %  lava
--     o  box           S  switch        D  door         /  open door
--     E  exit          h  hidden button: looks like a wall, but can be pressed
--     1 ... 9          a sign. Its text goes in an extra line, like  "1: hello"
--     >  <  ^  v       the robot, looking right, left, up or down
--
--   levelTodo is what is written on the robot's todo stack at the start,
--   top note first. The robot can read it with  peek  and remove the top
--   note with  pop  once that task is done.
--
--   Want to make your own level? Copy one, change the map, and use it in
--   your levels/LevelN.hs file instead.
module Levels
  ( level1
  , level2
  , level3
  , level4
  , level5
  , level6
  , level7
  , level8
  , level9
  , level10
  , level11
  , level12
  , allLevels
  ) where

import Robot

-- | A list of moves.
level1 :: Level
level1 = Level
  { levelName = "Level 1: First steps"
  , levelTodo = []
  , levelMaps =
      [ [ "#######"
        , "#####E#"
        , "#####.#"
        , "#>....#"
        , "#######"
        ]
      ]
  }

-- | Longer lists: replicate and ++.
level2 :: Level
level2 = Level
  { levelName = "Level 2: The long way"
  , levelTodo = []
  , levelMaps =
      [ [ "################"
        , "#>.......%%%%%%#"
        , "########.%%%%%%#"
        , "%%%%%%%%.%%%%%%#"
        , "%%%%%%%%......E#"
        , "################"
        ]
      ]
  }

-- | Sensors and guards.
level3 :: Level
level3 = Level
  { levelName = "Level 3: Three tunnels"
  , levelTodo = []
  , levelMaps =
      [ [ "############"
        , "#>...#######"
        , "####.#%%%%%#"
        , "####.....%%#"
        , "########.E%#"
        , "############"
        ]
      , [ "##########"
        , "#v########"
        , "#.#..E%%%#"
        , "#.#.######"
        , "#...%%%%%#"
        , "##########"
        ]
      , [ "############"
        , "#>....######"
        , "%%%%%.%...E#"
        , "%%%%%.%.####"
        , "%%%%%...####"
        , "############"
        ]
      ]
  }

-- | grab, drop and holding.
level4 :: Level
level4 = Level
  { levelName = "Level 4: Puddles"
  , levelTodo = []
  , levelMaps =
      [ [ "##########"
        , "#>.o..~.E#"
        , "##########"
        ]
      , [ "################"
        , "#>o..~..o.~...E#"
        , "################"
        ]
      , [ "###"
        , "%v%"
        , "%o%"
        , "%.%"
        , "%~%"
        , "%.%"
        , "%o%"
        , "%.%"
        , "%~%"
        , "%E%"
        , "###"
        ]
      ]
  }

-- | press, and looking left and right.
level5 :: Level
level5 = Level
  { levelName = "Level 5: Doors"
  , levelTodo = []
  , levelMaps =
      [ [ "#############"
        , "###S#########"
        , "#>.......D.E#"
        , "#%%%%%%%%####"
        , "#############"
        ]
      , [ "#############"
        , "#>......D..E#"
        , "#####S#######"
        , "#############"
        ]
      , [ "##########"
        , "#>....D.E#"
        , "#S%%%%####"
        , "##########"
        ]
      ]
  }

-- | The todo stack: peek at the task, pop it when it's done.
level6 :: Level
level6 = Level
  { levelName = "Level 6: Don't press twice!"
  , levelTodo = ["press button", "go to end"]
  , levelMaps =
      [ [ "##########"
        , "#>.......#"
        , "#####S##.#"
        , "#ED......#"
        , "##########"
        ]
      , [ "##########"
        , "#ED......#"
        , "###S####.#"
        , "#>.......#"
        , "##########"
        ]
      ]
  }

-- | Everything together, one task after another.
level7 :: Level
level7 = Level
  { levelName = "Level 7: The big escape"
  , levelTodo = ["cross bridge", "press button", "go to end"]
  , levelMaps =
      [ [ "#############"
        , "#>.o.~....%%#"
        , "#########.%%#"
        , "#####S###.%%#"
        , "#ED.......%%#"
        , "#############"
        ]
      , [ "#####S####"
        , "#........#"
        , "#~######.#"
        , "#.%%%%%#.#"
        , "#o######D#"
        , "#.%%%%%#E#"
        , "#^########"
        , "##########"
        ]
      ]
  }

-- | Signs: count letters to find a hidden button.
level8 :: Level
level8 = Level
  { levelName = "Level 8: The hidden button"
  , levelTodo = ["read sign", "walk a bit", "go to end"]
  , levelMaps =
      [ [ "############"
        , "#1##h#######"
        , "#^......D.E#"
        , "############"
        , "1: xkcd banana pqz"
        ]
      , [ "############"
        , "#1####h#####"
        , "#^......D.E#"
        , "############"
        , "1: abracadabra"
        ]
      , [ "##########"
        , "#1#h######"
        , "#^.....###"
        , "%%%%%%.%%%"
        , "%%%%%%D%%%"
        , "%%%%%%E%%%"
        , "##########"
        , "1: zqaxwvpa"
        ]
      ]
  }

-- | Signs: a route to follow, with map.
level9 :: Level
level9 = Level
  { levelName = "Level 9: Follow the sign"
  , levelTodo = []
  , levelMaps =
      [ [ "##########"
        , "#1.......#"
        , "#^.%.....#"
        , "#..%.%%..#"
        , "#....%E..#"
        , "#..%.....#"
        , "##########"
        , "1: RFRFFLFFRFLFFLF"
        ]
      , [ "##########"
        , "#........#"
        , "#.%%.%%%.#"
        , "#.%E.%...#"
        , "#.%%%%.%.#"
        , "#.......v#"
        , "########1#"
        , "1: BFFFFLFFFFLFFRF"
        ]
      ]
  }

-- | Signs: the route is hidden in a sentence, with filter.
level10 :: Level
level10 = Level
  { levelName = "Level 10: Secret message"
  , levelTodo = []
  , levelMaps =
      [ [ "########"
        , "#1.....#"
        , "#^.%%..#"
        , "#..%E%.#"
        , "#......#"
        , "########"
        , "1: Run Fast, Rex! Find Food, Little Fox. Feed Lots First."
        ]
      , [ "##########"
        , "#...%%...#"
        , "#.%%E%.%.#"
        , "#.%....%.#"
        , "#.%%%%%%.#"
        , "#.......>1"
        , "##########"
        , "1: Look! Four Fat Frogs Fly. Lucky Frogs Fly Like Feathers. Funny Robots Find Five Rubber Fish."
        ]
      ]
  }

-- | push: remember the first sign while reading the second one.
level11 :: Level
level11 = Level
  { levelName = "Level 11: Torn map"
  , levelTodo = []
  , levelMaps =
      [ [ "##1#######"
        , "#.^......#"
        , "#.2%.%%..#"
        , "#...%E%..#"
        , "#.%......#"
        , "##########"
        , "1: LFFFFFRF"
        , "2: FFRFFRF"
        ]
      , [ "##########"
        , "#........#"
        , "#.%.%%%%.#"
        , "#2>1%E%%.#"
        , "#%..%.%..#"
        , "#%%....%.#"
        , "##########"
        , "1: LFLFRF"
        , "2: LFFLFF"
        ]
      ]
  }

-- | Everything: a bridge, a hidden button, a door and a secret route.
level12 :: Level
level12 = Level
  { levelName = "Level 12: The grand finale"
  , levelTodo = ["cross bridge", "find button", "follow route"]
  , levelMaps =
      [ [ "############"
        , "#>.o.~..####"
        , "#######.####"
        , "#..D....####"
        , "#.###h#1####"
        , "#.........##"
        , "#2%%.%%%..##"
        , "##%%E%....##"
        , "##%%%%....##"
        , "############"
        , "1: jzpandaq"
        , "2: Look For Four Fresh Red Flying Fish!"
        ]
      , [ "############"
        , "####..~.o.<#"
        , "####.#######"
        , "####.#######"
        , "#....#######"
        , "#.#h1#######"
        , "#D##########"
        , "#.........##"
        , "#2%%%%.%..##"
        , "##%%%%E%..##"
        , "##%%%%%%..##"
        , "############"
        , "1: xqzwa"
        , "2: Little Frogs Find Five Fat Flies, Really Funny Frogs!"
        ]
      ]
  }

allLevels :: [Level]
allLevels =
  [ level1, level2, level3, level4, level5, level6
  , level7, level8, level9, level10, level11, level12 ]
