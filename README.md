# ***Polyphony*** `v0.3.2 (initium)` *for Sonic Pi*

## Contents

- [Intro](#intro)
- [Setup](#setup)
- [Quick Settings](#quick-settings)
- [Questions and Comments](#questions-and-comments)

## Intro

Make music with *Polyphony*. Ideate. Compose. Perform.

This project is under active development.

## MIDI Setup

1. On line 1 of `main.rb`, replace the `DIRECTORY` string with the location of the project
2. Within the `selection` array in `"settings/voices"` in `settings.rb`, comment/uncomment desired sections to play.
3. Set up new instruments as desired:
 - within `INSTRUMENTS` on line 1 in `ensembles.rb`, enter new instruments (use an existing instrument as a template!)
 - within `ensembles` below `INSTRUMENTS` in `ensembles.rb`, enter new ensembles using instruments from `INSTRUMENTS`
 - for `ensemble` in `"settings/voices/articulated"` and `"settings/voices/sustained"` of `settings.rb`, replace the symbols with the appropriate ensemble
4. under `ports` in `"settings/voices/articulated"` and `"settings/voices/sustained"` of `settings.rb`, replace the array entries with the appropriate MIDI out ports
5. In Sonic Pi, run the following: `run_file("LOCATION")`, replacing `LOCATION` with the location of the project

## Quick Settings

All settings can be found in `settings.rb`.

### `"settings/general"`

Setting               | Values                  | Description
---                   | ---                     | ---
`seed`                | int \[0,)               | random seed

### `"settings/metronome"`

Setting               | Values                  | Description
---                   | ---                     | ---
`unitsPerMinute`      | (0,)                    | tempo
`timeLimitInMinutes`  | \[0,) \|\| nil          | nil performs forever

### `"settings/space"`

Setting               | Values                             | Description
---                   | ---                                | ---
`initialKey`          | int 0-11, [any heptatonic scale]   | key signature (0-11 corresponds to C-B)

### `"settings/voices"`

Setting               | Values                         | Description
---                   | ---                            | ---
`active`              | `"articulated"`, `"sustained"` | voice sections to use

### `"settings/voices/articulated"`

Setting               | Values                               | Description
---                   | ---                                  | ---
`ensemble`            | (see `ensembles` in `ensembles.rb`)  | ensemble to use
`ports`               | MIDI out port from sonic pi          | ports to use

### `"settings/voices/sustained"`

Setting               | Values                               | Description
---                   | ---                                  | ---
`ensemble`            | (see `ensembles` in `ensembles.rb`)  | ensemble to use
`ports`               | MIDI out port from sonic pi          | ports to use

## Questions and Comments

The GitHub wiki offers a more in-depth look at the program. That said, a lot is to be figured out from playing with the source code itself.

Please feel free to reach out to me on Twitter! ([\@0delphini](https://twitter.com/0delphini))
