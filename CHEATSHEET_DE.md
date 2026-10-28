# Roboter-Spickzettel

```haskell
step :: Sensors -> [Move]
step s = [move F, turn L, move F]
```

`step` bekommt, was der Roboter sieht (`s`), und gibt eine **Liste von Zügen**
zurück. Wenn die Liste aufgebraucht ist, wird `step` mit neuen Sensorwerten
wieder aufgerufen.

## Was jedes Level beibringt

| Level | Name               | Neu                                                          |
|-------|--------------------|--------------------------------------------------------------|
| 1     | First steps        | eine Liste von Zügen: `[move F, turn L]`                     |
| 2     | The long way       | `replicate`, `++`                                            |
| 3     | Three tunnels      | Sensoren (`blockF s`), Guards (`\|`, `==`, `otherwise`)      |
| 4     | Puddles            | `grab`, `drop`, `holding s`, `Nothing` / `Just Box`, `&&`    |
| 5     | Doors              | `press`, `blockL s`, `blockR s`                              |
| 6     | Don't press twice! | der Todo-Stapel: `peek s`, `pop`                             |
| 7     | The big escape     | eigene Hilfsfunktionen, eine für jede Aufgabe                |
| 8     | The hidden button  | Schilder: `read s`, `filter`, `length`, versteckte Knöpfe    |
| 9     | Follow the sign    | `map`, eine Zeile pro Buchstabe (`'F'`, `_`)                 |
| 10    | Secret message     | `filter` mit `elem`                                          |
| 11    | Torn map           | `push (read s)` zum Merken, `case`, um den Text aus `Just` zu holen |
| 12    | The grand finale   | alles zusammen                                               |

## Züge

| Zug              | Was er macht                                          |
|------------------|-------------------------------------------------------|
| `move F`         | ein Feld vorwärts fahren                              |
| `move B`         | ein Feld rückwärts fahren                             |
| `turn L`         | nach links drehen                                     |
| `turn R`         | nach rechts drehen                                    |
| `turn B`         | umdrehen                                              |
| `grab`           | die Kiste vor dem Roboter aufheben                    |
| `drop`           | die Kiste vor dem Roboter abstellen (ins Wasser: füllt es auf) |
| `press`          | den Schalter vor dem Roboter drücken (öffnet / schliesst alle Türen) |
| `push "notiz"`   | eine Notiz oben auf den Todo-Stapel legen             |
| `pop`            | die oberste Notiz wegwerfen                           |

Die Buchstaben stehen für die englischen Wörter:
**F** = forwards (vorwärts), **B** = backwards (rückwärts),
**L** = left (links), **R** = right (rechts).

## Sensoren

| Sensor         | Antwort                                               |
|----------------|-------------------------------------------------------|
| `blockF s`     | der Block vor dem Roboter (`F`), auch `blockL`, `blockR`, `blockB` |
| `look F 2 s`   | der Block 2 Felder vor dem Roboter (jede Richtung, jede Entfernung) |
| `holding s`    | `Nothing` (nichts) oder `Just Box` (eine Kiste)       |
| `peek s`       | die oberste Notiz: `Nothing` oder `Just "notiz"`      |
| `position s`   | wo der Roboter ist: `(x, y)`                          |
| `facing s`     | `North`, `East`, `South` oder `West` (Norden, Osten, Süden, Westen) |
| `read s`       | der Text auf dem Schild vor dem Roboter, `""` wenn keins da ist |
| `free b`       | `True`, wenn der Roboter auf Block `b` fahren kann    |

## Blöcke

| Block      | Bedeutung     | Block      | Bedeutung         |
|------------|---------------|------------|-------------------|
| `Floor`    | Boden         | `Box`      | Kiste             |
| `Wall`     | Wand          | `Switch`   | Schalter          |
| `Water`    | Wasser        | `Door`     | geschlossene Tür  |
| `Lava`     | Lava          | `OpenDoor` | offene Tür        |
| `Exit`     | Ausgang       | `Sign`     | Schild            |

Ein **versteckter Knopf** sieht aus wie eine `Wall`, sogar für die Sensoren.
Aber `press` funktioniert bei ihm wie bei einem Schalter.

## Auf dem Bildschirm

| Bild    | Bedeutung | Bild    | Bedeutung         |
|---------|-----------|---------|-------------------|
| `@>`    | Roboter   | `[]`    | Kiste             |
| `##`    | Wand      | `()`    | Schalter          |
| `~~`    | Wasser    | `\|\|`  | geschlossene Tür  |
| `^^`    | Lava      | `__`    | offene Tür        |
| ` .`    | Boden     | `EX`    | Ausgang           |
| `!!`    | Schild    |         |                   |

## Das Level ist verloren, wenn der Roboter...

- gegen eine Wand, eine Kiste, einen Schalter, ein Schild oder eine geschlossene Tür fährt
- ins Wasser oder in die Lava fährt
- `press` macht, obwohl kein Schalter vor ihm ist
- `grab` macht, obwohl keine Kiste da ist, oder `drop`, obwohl er nichts trägt
- mit der Kiste, die er trägt, irgendwo anstösst

Fährt der Roboter endlos im Kreis? Mit **Ctrl+C** (Strg+C) hältst du ihn an.

## Der Todo-Stapel

Der Todo-Stapel ist ein Stapel Notizen. Der Roboter kann nur die oberste Notiz
sehen (`peek`), eine neue Notiz oben drauf legen (`push`) oder die oberste
wegwerfen (`pop`).

Manche Levels fangen mit Aufgaben auf dem Stapel an, zum Beispiel:
`"cross bridge"` (Brücke bauen) oben, dann `"press button"` (Knopf drücken),
dann `"go to end"` (zum Ausgang).

```haskell
step s
  | peek s == Just "cross bridge" = crossBridge s   -- die oberste Aufgabe erledigen
  | peek s == Just "press button" = pressButton s
  | otherwise                     = goToEnd s

-- wenn eine Aufgabe fertig ist, wirf sie weg:   [drop, pop]
```

## Haskell-Hilfe

```haskell
replicate 3 (move F)          -- [move F, move F, move F]
[move F] ++ [turn L]          -- [move F, turn L]   (++ hängt Listen zusammen)

step s
  | blockF s == Wall  = [turn L]       -- die erste passende Zeile gilt
  | blockF s /= Floor = [turn R]       -- /=  heisst "ist nicht"
  | free (blockL s) && holding s == Nothing = [turn L]   -- && heisst "und"
  | otherwise         = [move F]       -- otherwise heisst "sonst"
```

Mit Text arbeiten (ein `String` ist eine Liste von Buchstaben):

```haskell
length "hallo"                    -- 5
filter (== 'l') "hallo"           -- "ll"
elem 'R' "FLRB"                   -- True: ist 'R' in "FLRB"?
map toMove "FFR"                  -- [toMove 'F', toMove 'F', toMove 'R']

toMove :: Char -> Move            -- eine Zeile für jeden Buchstaben
toMove 'F' = move F
toMove 'R' = turn R
toMove _   = turn B               -- _ heisst "irgendein anderer Buchstabe"
```

Die Notiz aus `Just` herausholen:

```haskell
note :: Sensors -> String
note s = case peek s of
  Just text -> text                -- es gibt eine Notiz: hier ist sie
  Nothing   -> ""                  -- der Stapel ist leer

"LFF" ++ "RF"                      -- "LFFRF": ++ hängt auch Texte zusammen
```

## Befehle

```
cabal run level3          Level 3 spielen
cabal run explore         den Roboter von Hand steuern, alle Sensoren sehen

cabal repl level3         Sachen ausprobieren:
  main                    spielen
  playSlow level3 step    in Zeitlupe
  check level3 step       ohne Animation, nur das Ergebnis
  replicate 3 (move F)    irgendein Ausdruck: die repl zeigt die Antwort
  :r                      nach einer Änderung neu laden
  :q                      beenden
```
