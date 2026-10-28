# Robot escape: Haskell for beginners

The kids program a robot by writing a single function:

```haskell
step :: Sensors -> [Move]
```

`step` gets the robot's sensors and returns the next moves, for example
`[move F, grab, turn R, move F, drop]`. When the moves are used up, `step` is
called again with fresh sensors. This repeats until the robot reaches the
exit or the level is lost.

## Running

You need GHC and cabal, for example from [ghcup](https://www.haskell.org/ghcup/).
The only dependencies are `base` and `containers`, which come with GHC.

```
cabal build all               build everything once (the first time takes a moment)

cabal run level1              play level 1 (level1 ... level12)
cabal repl level1             try things out: type  main , and  :r  after changes
cabal run explore             drive the robot by hand, see every move and sensor

cabal run solutions           watch every example solution, one level after another
cabal run solutions -- 8      watch the solution of level 8
cabal run solutions -- 120    watch all of them, 120 ms between moves
cabal run solutions -- 8 120  level 8 with 120 ms between moves (120 8 works too)
cabal run solutions -- check  quickly check that every level is solved
```

`solutions` takes up to two numbers in any order. A number from 1 to the
number of levels picks a level, and a bigger number is the delay in
milliseconds (default 250).

The code of the solutions is in `solutions/Solutions.hs`.

The game draws with ANSI colour codes. Any Linux or macOS terminal works, and
on Windows the VS Code terminal and Windows Terminal do.

## Files

| Path                   | For whom | Contents                                              |
|------------------------|----------|-------------------------------------------------------|
| `levels/Level1-12.hs`  | kids     | one file per level: explains the new idea, `step` stub |
| `CHEATSHEET.md`        | kids     | all moves, sensors and rules on one page              |
| `CHEATSHEET_DE.md`     | kids     | the same in German                                    |
| `src/Levels.hs`        | both     | the maps as ASCII art. Easy to change or extend        |
| `src/Robot.hs`         | teacher  | what the level files can use                          |
| `src/Robot/Core.hs`    | teacher  | world, sensors, moves and rules                       |
| `src/Robot/Draw.hs`    | teacher  | drawing in the terminal                               |
| `src/Robot/Play.hs`    | teacher  | running a `step` function, catching crashes            |
| `src/Robot/Explore.hs` | teacher  | the explorer                                          |
| `solutions/`           | teacher  | example solutions                                     |

## The explorer

`cabal run explore` lists all levels. Pick one and type moves by hand
(`move F`, `turn L`, `grab`, `push "hello"`, ...). After every move it shows
what each sensor reads (`blockF s = Water`, `holding s = Just Box`,
`peek s = Just "cross bridge"`, ...) and explains what the move did. `undo`
takes a move back, `next` switches to the next map, `help` lists everything.

It also keeps the list of moves typed so far, which the kids can copy into
level 1 or 2 as their `step`.

## The levels

Levels 3 to 12 have several maps, and one `step` must solve all of them. A
hardcoded list of moves fails on the second map, so the kids have to use the
sensors.

| Level | Maps | New idea                                  | Solution idea                           |
|-------|------|-------------------------------------------|-----------------------------------------|
| 1     | 1    | a list of moves                           | `[move F, move F, ..., turn L, ...]`    |
| 2     | 1    | `replicate`, `++`                         | `replicate 7 (move F) ++ [turn R] ++ ...` |
| 3     | 3    | sensors, guards, `step` is called again   | follow the tunnel: forward, else left, else right |
| 4     | 3    | `grab`, `drop`, `holding`, `&&`, `Maybe`  | box ahead: grab, water ahead: drop      |
| 5     | 3    | `press`, side sensors                     | switch on the side: turn, press, turn back, **move on** |
| 6     | 2    | the todo stack: `peek`, `pop`             | starts with `"press button"` on top. Press, then `pop` |
| 7     | 2    | one function per task                     | tasks `"cross bridge"`, `"press button"`, `"go to end"` |
| 8     | 3    | `read`, `filter`, `length`                | count the `'a'`s on the sign = distance to the hidden button |
| 9     | 2    | `map`, pattern matching on `Char`         | the sign is a route: `map toMove (read s)` |
| 10    | 2    | `filter` with `elem`, lambdas             | the route is the capital letters F, L, R, B in a sentence |
| 11    | 2    | `push` to remember, `case` on `Maybe`     | push sign 1, turn around, drive `firstHalf s ++ read s` |
| 12    | 2    | everything                                | tasks `"cross bridge"`, `"find button"`, `"follow route"` |

### The sign levels

`read s` gives the text on the sign in front of the robot (`""` if there is
none). The text is the puzzle input, and the kids compute the solution from it:

- **Level 8:** the sign holds a jumble like `"xkcd banana pqz"`. Turn right, drive
  as many fields as there are `'a'`s, and the hidden button is on the left.
  Hidden buttons look like walls on screen and to every sensor, and pressing a
  real wall loses, so the count has to be right. The whole plan is computed in
  one `step` while the sign is still in front:
  `[turn R] ++ replicate (length (filter (== 'a') (read s))) (move F) ++ [turn L, press, turn R, pop]`.
- **Level 9:** the sign holds a route like `"RFRFFLF"`. The rooms are built so
  that following the walls (the level 3 solution) circles forever around an exit
  in the middle. So the kids have to read the sign.
- **Level 10:** the route is the capital letters of a sentence like
  `"Run Fast, Rex! Find Food, Little Fox..."`. The level 9 solution drives into
  the lava, because the lowercase letters and punctuation have to be filtered
  out first.
- **Level 11:** the robot stands between two signs, each with half of a route.
  `read` only sees the sign in front, so the robot has to `push (read s)`, turn
  around, and combine the remembered half with the second sign:
  `map toMove (firstHalf s ++ read s)`, where `firstHalf` gets the text out of
  `peek s` with `case`. Using only one sign, or the halves in the wrong order,
  fails.
- **Level 12:** the finale. The stack starts with three tasks: build the bridge
  (level 4), count the letters on a sign to find the hidden button that opens
  the door (level 8), and follow the route hidden in a sentence (level 10). The
  solution is the earlier helper functions, chosen by the top task.

Two traps that lead to good discussions:

- **Level 5:** `[turn L, press, turn R]` without a `move F` makes `step` see the
  switch again and press it again. The door opens and closes forever, until
  someone presses Ctrl+C.
- **Level 6:** the robot passes the switch twice, and pressing both times closes
  the door again. The task on top of the stack tells the robot what it is doing
  right now. Popping `"press button"` after pressing switches it to the next
  behaviour.

## The todo stack as memory

`step` is a pure function and remembers nothing between calls, so the todo
stack is the robot's only memory. The robot can only use it like a real stack:
`peek s` shows the top note, `push` puts a note on top, `pop` removes it. There
is no way to read the whole stack.

Each level can start the robot with tasks on the stack (`levelTodo` in
`src/Levels.hs`, top first). A typical solution picks a behaviour by the top
note and pops it when that task is done:

```haskell
step s
  | peek s == Just "cross bridge" = crossBridge s
  | peek s == Just "press button" = pressButton s
  | otherwise                     = goToEnd s

crossBridge s
  | holding s == Nothing && blockF s == Box   = [grab]
  | holding s /= Nothing && blockF s == Water = [drop, pop]   -- done: next task
  | otherwise                                 = [move F]
```

The screen shows the whole stack, so the kids can follow what happens.

## Rules

- Driving into `Wall`, `Box`, `Switch`, `Sign` or a closed `Door`, or into
  `Water` or `Lava`, loses the level.
- `move L` and `move R` lose: the robot has to turn first.
- A carried box floats in the field in front of the robot. If it bumps into
  something solid while the robot drives or turns, the level is lost.
- `drop` on floor puts the box down. Into water it fills the water, which becomes
  floor. Into lava the box melts.
- `press` with no switch (or hidden button) in front loses. A switch toggles all
  doors.
- `grab` with no box in front, or while already carrying one, loses. So does
  `drop` with empty hands.
- Reaching the exit wins, even while carrying a box.
- There is no move limit when playing: a robot driving in circles keeps going
  until Ctrl+C. Only `check` (and the solution checker) stop after 1000 moves,
  so they always finish.
- `step` returning `[]`, crashing (for example `head []`), or computing for more
  than 3 seconds ends the map with a readable message instead of a Haskell
  error.

## Making new levels

Maps in `src/Levels.hs` are plain strings:

```
#  wall     .  floor    ~  water    %  lava     o  box
S  switch   D  door     /  open door            E  exit
h  hidden button (looks like a wall, works like a switch)
1 ... 9     a sign
>  <  ^  v  the robot, looking right / left / up / down
```

A sign's text goes in an extra line below the map, starting with its digit:

```haskell
[ "#######"
, "#1.h..#"
, "#^...E#"
, "#######"
, "1: count my letters"
]
```

Copy a level, draw a map, set its `levelTodo` (or leave it `[]`), and add it
to `allLevels` so the explorer shows it. For a new level file, copy
`levels/Level12.hs` and add an `executable` for it in `robot-escape.cabal`.
Letting the kids design maps for each other is a good last exercise.

Note: `Robot` exports a move called `drop` and a sensor called `read`, which
clash with `drop` and `read` from the Prelude. That's why every level file
starts with `import Prelude hiding (drop, read)`.
