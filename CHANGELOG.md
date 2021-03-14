## History

v0.3.0 (2021-03-14)
- [log](#v0.3.0)
- [commits]("")

<hr/>

### v0.3.0

This version is a complete rewrite of the project, which was previously referred to as "motifs", "phrases", and "sections". The code has been organised into files and rewritten for clarity and maintainability. Towards that end, functions within each file have been categorised as generalised and specialised. Generalised functions are modular and depend only on the parameters supplied to them. Specialised functions are tied to the project's time-state global variables.

The newly created files each reflect an aspect (if not an explicit component) of the program. The main file is kept abstract. All settings are collected into the settings file for ease of use. The programmer-user can keep copies of their configurations for future use.

This version is the first to be documented and integrated with version control. Previous programs were more prototypal in nature. It is almost likely that sweeping changes may still be made and that this program may be completely rewritten and re-organised. In light of that, the programmer-user should expect breaking changes in the future. Hence, this is not yet version 1.0.0.
