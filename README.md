# ***Polyphony*** `v0.3.4 (initium)` *for Sonic Pi*

## Contents

- [Intro](#intro)
- [Setup](#setup)
- [Quick Settings](#quick-settings)
- [Questions and Comments](#questions-and-comments)

## Intro

Make music with *Polyphony*. Ideate. Compose. Perform.

This project is under active development.

## Setup

1. On line 1 of `main.rb`, replace the `DIRECTORY` string with the location of the project
1. Within the `selection` array in `"settings/voices"` in `settings.rb`, comment/uncomment desired sections to play
1. (optional) [Set up your own ensemble!](#ensemble-setup)
1. In Sonic Pi, run the following: `run_file "LOCATION/20210303-polyphony/main.rb"`, replacing `LOCATION` with the location of the project (e.g. `run_file "~/OneDrive/music-production/sonic-pi/20210303-polyphony/main.rb"`)

## Ensemble Setup

N.B. MIDI instruments should be placed *before* Sonic Pi instruments, so that channels align as expected.

- within `MIDI_INSTRUMENTS` in `ensembles.rb`, enter new instruments (use an existing instrument as a template!)
- within `SPI_INSTRUMENTS` in `ensembles.rb`, enter new instruments (use an existing instrument as a template!)
- within the appropriate `"ensembles"` in `ensembles.rb` (i.e. `"ensembles/fusion"`, `"ensembles/midi"`, or `"ensembles/spi"`), create a new ensemble using instruments from `MIDI_INSTRUMENTS` and/or `SPI_INSTRUMENTS`
- for `ensemble` in `"settings/voices/articulated" > performance` and `"settings/voices/sustained" > performance` of `settings.rb`, set the appropriate ensembles (use the existing setting as a template)
- if using MIDI:
	- set up (a) MIDI cable(s) and make sure Sonic Pi recognises it as (a) MIDI out port(s)
	- under `ports` in `"settings/voices/articulated"` and `"settings/voices/sustained"` of `settings.rb`, replace the array entries with the appropriate MIDI out ports, as named in Sonic Pi
	- set the MIDI channels at your endpoint (DAW and/or hardware) to correspond with the instruments in the ensemble (starting with channel 1 for the first instrument)
	- N.B. any instruments (of any kind) more than 16 will automatically be mapped to the next MIDI port(s), because each MIDI port only has 16 channels
- Proceed with [setup](#setup)

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
