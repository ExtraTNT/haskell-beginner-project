# Robot cheat sheet

```haskell
step :: Sensors -> [Move]
step s = [move F, turn L, move F]
```

`step` gets what the robot sees (`s`) and gives back a **list of moves**.
When the list is used up, `step` is called again with new sensor values.

## What each level teaches

| Level | Name               | New                                                         |
|-------|--------------------|-------------------------------------------------------------|
| 1     | First steps        | a list of moves: `[move F, turn L]`                         |
| 2     | The long way       | `replicate`, `++`                                           |
| 3     | Three tunnels      | sensors (`blockF s`), guards (`\|`, `==`, `otherwise`)      |
| 4     | Puddles            | `grab`, `drop`, `holding s`, `Nothing` / `Just Box`, `&&`   |
| 5     | Doors              | `press`, `blockL s`, `blockR s`                             |
| 6     | Don't press twice! | the todo stack: `peek s`, `pop`                             |
| 7     | The big escape     | your own helper functions, one for each task                |
| 8     | The hidden button  | signs: `read s`, `filter`, `length`, hidden buttons         |
| 9     | Follow the sign    | `map`, one line per letter (`'F'`, `_`)                     |
| 10    | Secret message     | `filter` with `elem`                                        |
| 11    | Torn map           | `push (read s)` to remember, `case` to get the text out of `Just` |
| 12    | The grand finale   | everything together                                         |

## Moves

| Move             | What it does                                         |
|------------------|------------------------------------------------------|
| `move F`         | drive one field forwards                             |
| `move B`         | drive one field backwards                            |
| `turn L`         | turn left                                            |
| `turn R`         | turn right                                           |
| `turn B`         | turn around                                          |
| `grab`           | pick up the box in front                             |
| `drop`           | put the box down in front (in water: fills it up)    |
| `press`          | press the switch in front (opens / closes all doors) |
| `push "note"`    | put a note on top of the todo stack                  |
| `pop`            | throw away the top note                              |

## Sensors

| Sensor         | Answer                                              |
|----------------|-----------------------------------------------------|
| `blockF s`     | the block in front (`F`), also `blockL`, `blockR`, `blockB` |
| `look F 2 s`   | the block 2 fields in front (any direction, any distance) |
| `holding s`    | `Nothing` or `Just Box`                             |
| `peek s`       | the top note: `Nothing` or `Just "note"`            |
| `position s`   | where the robot is: `(x, y)`                        |
| `facing s`     | `North`, `East`, `South` or `West`                  |
| `read s`       | the text on the sign in front, `""` if there is none |
| `free b`       | `True` if the robot can drive onto block `b`        |

Blocks: `Floor` `Wall` `Water` `Lava` `Box` `Switch` `Door` `OpenDoor` `Sign` `Exit`

A **hidden button** looks like a `Wall`, even to the sensors. But `press`
works on it like on a switch.

## On the screen

| Picture | Meaning   | Picture | Meaning        |
|---------|-----------|---------|----------------|
| `@>`    | robot     | `[]`    | box            |
| `##`    | wall      | `()`    | switch         |
| `~~`    | water     | `\|\|`  | closed door    |
| `^^`    | lava      | `__`    | open door      |
| ` .`    | floor     | `EX`    | exit           |
| `!!`    | sign      |         |                |

## The level is lost when the robot...

- drives into a wall, a box, a switch, a sign or a closed door
- drives into water or lava
- presses when there is no switch in front
- grabs when there is no box, or drops when it carries nothing
- bumps the box it carries into something

Driving in circles forever? Press **Ctrl+C** to stop the robot.

## The todo stack

The todo stack is a pile of notes. The robot can only see the top note
(`peek`), put a new note on top (`push`) or throw the top note away (`pop`).

Some levels start with tasks on the stack, for example:
`"cross bridge"` on top, then `"press button"`, then `"go to end"`.

```haskell
step s
  | peek s == Just "cross bridge" = crossBridge s   -- do the task on top
  | peek s == Just "press button" = pressButton s
  | otherwise                     = goToEnd s

-- when a task is done, pop it:   [drop, pop]
```

## Haskell help

```haskell
replicate 3 (move F)          -- [move F, move F, move F]
[move F] ++ [turn L]          -- [move F, turn L]

step s
  | blockF s == Wall  = [turn L]       -- the first line that fits is used
  | blockF s /= Floor = [turn R]       -- /=  means "is not"
  | free (blockL s) && holding s == Nothing = [turn L]   -- && means "and"
  | otherwise         = [move F]
```

Working with text (a `String` is a list of letters):

```haskell
length "hello"                    -- 5
filter (== 'l') "hello"           -- "ll"
elem 'R' "FLRB"                   -- True: is 'R' in "FLRB"?
map toMove "FFR"                  -- [toMove 'F', toMove 'F', toMove 'R']

toMove :: Char -> Move            -- one line for each letter
toMove 'F' = move F
toMove 'R' = turn R
toMove _   = turn B               -- _ means "any other letter"
```

Getting the note out of `Just`:

```haskell
note :: Sensors -> String
note s = case peek s of
  Just text -> text                -- there is a note: here it is
  Nothing   -> ""                  -- the stack is empty

"LFF" ++ "RF"                      -- "LFFRF": ++ glues texts too
```

## Commands

```
cabal run level3          play level 3
cabal run explore         drive the robot by hand, see every sensor

cabal repl level3         try things out:
  main                    play
  playSlow level3 step    slow motion
  check level3 step       no animation, just the result
  replicate 3 (move F)    any expression: the repl shows the answer
  :r                      reload after changing the file
  :q                      quit
```
