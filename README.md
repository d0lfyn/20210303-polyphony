# ***Polyphony*** `v0.4.0 (initium)` *for Sonic Pi*

## Contents

- [Intro](#intro)
- [Setup](#setup)
- [Ensemble Setup](#ensemble-setup)
- [Quick Settings](#quick-settings)
- [Questions and Comments](#questions-and-comments)

## Intro

Make music with *Polyphony*. Ideate. Compose. Perform.

This project is under active development.

## Setup

In Sonic Pi, run the following:
```rb
load "LOCATION/20210323-polyphony/polyphony.rb"
run
```
Replace `LOCATION` with the location of the project. E.g.
```rb
load "~/OneDrive/music-production/sonic-pi/20210323-polyphony/polyphony.rb"
run
```

## Ensemble Setup

N.B. MIDI instruments should be placed *before* Sonic Pi instruments, so that channels align as expected.

Within `settings.rb`:
- enter/edit instruments in `MIDI_INSTRUMENTS`
- enter/edit instruments in `SPI_INSTRUMENTS`
- enter/edit an array of instruments in `ENSEMBLES`
- for `ensemble` in `ARTICULATED > performance` and `SUSTAINED > performance` of `settings.rb`, set the appropriate ensembles
- if using MIDI:
  - set up (a) MIDI cable(s) and make sure Sonic Pi recognises it as (a) MIDI out port(s)
  - under `ports` in `ARTICULATED > performance > midi` and `SUSTAINED > performance > midi`, replace the array entries with the appropriate MIDI out ports, as named in Sonic Pi
  - set the MIDI channels at your endpoint (DAW and/or hardware) to correspond with the instruments in the ensemble (starting with channel 1 for the first instrument)
  - N.B. any instruments (of any kind) more than 16 will automatically be mapped to the next MIDI port(s), because each MIDI port only has 16 channels

## Quick Settings

All settings can be found in `settings.rb`.

### `RANDOM`

Setting               | Values                  | Description
---                   | ---                     | ---
`seed`                | int \[0,\]              | random seed

### `SPACE`

Setting               | Values                             | Description
---                   | ---                                | ---
`initialKey`          | int 0-11, [any heptatonic scale]   | key signature (0-11 corresponds to C-B)

### `TIMEKEEPING`

Setting               | Values                  | Description
---                   | ---                     | ---
`unitsPerMinute`      | (0,)                    | tempo
`timeLimitInUnits`    | \[0,\] \|\| nil         | nil performs forever

### `VOICES`

Setting               | Values                         | Description
---                   | ---                            | ---
`selection`           | `"articulated"`, `"sustained"` | voice sections to use

### `ARTICULATED` and `SUSTAINED`

Setting               | Values                               | Description
---                   | ---                                  | ---
`ensemble`            | (ensembles from `ENSEMBLE`)          | ensemble to use
`ports`               | MIDI out port from sonic pi          | ports to use

## Questions and Comments

The GitHub wiki offers a more in-depth look at the program. That said, a lot is to be figured out from playing with the source code itself.

Please feel free to reach out to me on Twitter! ([\@0delphini](https://twitter.com/0delphini))
