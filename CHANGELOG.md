# History

v0.3.0 (2021-03-14)
- [log](#v0.3.0)
- [tag](https://github.com/dolphinOfDelphi/20210303-polyphony/releases/tag/v0.3.0)

v0.4.0 (2021-03-28)
- [log](#v0.4.0)
- [tag](https://github.com/dolphinOfDelphi/20210303-polyphony/releases/tag/v0.4.0)

v0.4.1 (2021-04-xx)
- [log](#v0.4.1)

<hr/>

## v0.3.0

This version is a complete rewrite of the project, which was previously referred to as "motifs", "phrases", and "sections". The code has been organised into files and rewritten for clarity and maintainability. Towards that end, functions within each file have been categorised as generalised and specialised. Generalised functions are modular and depend only on the parameters supplied to them. Specialised functions are tied to the project's time-state global variables.

The newly created files each reflect an aspect (if not an explicit component) of the program. The main file is kept abstract. All settings are collected into the settings file for ease of use. The programmer-user can keep copies of their configurations for future use.

This version is the first to be documented and integrated with version control. Previous programs were more prototypal in nature. It is almost likely that sweeping changes may still be made and that this program may be completely rewritten and re-organised. In light of that, the programmer-user should expect breaking changes in the future. Hence, this is not yet version 1.0.0.

## v0.4.0

This version is another complete rewrite of the project. The code has been refactored to use Ruby modules and classes. The justification for this is that a modular design is more organised and can be recognised by code editors as standard Ruby code, which aids maintenance and navigation.

Also, the code is now documented using the YARD standard. This makes it easy to learn how components fit together, from a glance at a code editor such as VSCode with appropriate plugins such as Solargraph.

This work lays a solid foundation for further developments.

Important updates from [v0.3.0](#v0.3.0) are:

- a revised MIDI CC system, with improved behaviour and variety
- expanded frequency space possibilities, in terms of scales and modulations
- implementation of a subsystem for Sonic Pi synths, with instruments that can be used together with MIDI instruments
- improved musicality with conclusion passages for the articulated performance section
- additional default instruments
- simplified ensembles
- preparation of a human-readable meta-data document (`entry.catalogue.md`)
- preparation of functions and setting for custom motif input
- improved logging format

Future updates should address:

- idea development (with Markov matrices)
- percussion
- customisation (with a complementary GUI app)
- testing
- extensive logging (with files)

### v0.4.1

This version implements Markov matrices for idea displacements as a motif property that is interpreted during performance. This adds variety to the music while maintaining a sense of familiarity and coherence.

Minor changes are:

- additional default heptatonic scales (i.e. the harmonic and melodic minor scales, as well as the super locrian)
- renaming instruments and ensembles for consistency of capitalisation
- renaming the `ensembles.rb` file to `instruments.rb`, since the module contained therein only contains instrument classes
- adding an initial delay time before changes of space and state begin
