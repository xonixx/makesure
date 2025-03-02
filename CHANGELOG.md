## v0.9.24

- Implemented [@calls](https://makesure.dev/Directives-@calls.html) directive [#171](https://github.com/xonixx/makesure/issues/171)
- Fix `--selfupdate` [#174](https://github.com/xonixx/makesure/issues/174)
- Fixes and improvements.

## v0.9.23

- Allow glob to be interpolated string to facilitate reuse [#165](https://github.com/xonixx/makesure/issues/165)
- Minor improvements and fixes.

## v0.9.22
- Main theme of this release is allowing glob goals to be parameterized [#155](https://github.com/xonixx/makesure/issues/155)
- Support interpolation including parameterized goal params [#153](https://github.com/xonixx/makesure/issues/153)
- Fixes and improvements.

## v0.9.21
- Main theme of this release is revamping `@define` [#140](https://github.com/xonixx/makesure/issues/140)
- Ability to reference `@define`-d variables in parameterized dependencies [#139](https://github.com/xonixx/makesure/issues/139)
- Fixes and refactorings.

## v0.9.20
- Parameterized goals [#115](https://github.com/xonixx/makesure/issues/115).
- Fixes and refactorings.

## v0.9.19
- Minor fixes to `@reached_if` in [#113](https://github.com/xonixx/makesure/issues/113)
- Minor fixes to `@lib` in [#111](https://github.com/xonixx/makesure/issues/111)

## v0.9.18
- Optimizations and fixes to `@reached_if` handling in [#104](https://github.com/xonixx/makesure/issues/104) and [#29](https://github.com/xonixx/makesure/issues/29) (thanks @08d2)
- Added autocompletion script for bash in [#75](https://github.com/xonixx/makesure/issues/75)

## v0.9.17
- Allows `@define` in any position in file [#95](https://github.com/xonixx/makesure/issues/95)

## v0.9.16
Minor improvements and fixes.

## v0.9.15
The main theme for the release was reconsidering the notion of prelude. See the details in [#84](https://github.com/xonixx/makesure/issues/84).

## v0.9.14
- Make `@use_lib` apply also to `@reached_if` [#76](https://github.com/xonixx/makesure/issues/76) (thanks @pcrockett)
- Minor bug fixes

## v0.9.13
- Improvements to glob goal to support Bash glob features

## v0.9.12
1. Improve parser to allow spaces in goal names and comments [#63](https://github.com/xonixx/makesure/issues/63) 
2. Fixed bug with natural ordering in `@goal @glob` [#64](https://github.com/xonixx/makesure/issues/64) 
3. Minor improvements/fixes

## v.0.9.11
1. Improved precision of timings on macOS when using Gawk: [#57](https://github.com/xonixx/makesure/issues/57) 
2. Improved CI setup for runing tests with major Awk implementations: [#58](https://github.com/xonixx/makesure/issues/58) 
3. Updates should be more consistent with [#60](https://github.com/xonixx/makesure/issues/60) 

## v.0.9.10
1. Fixed timings on Mac [#50](https://github.com/xonixx/makesure/issues/50) 
2. Enhanced `@goal @glob` [#46](https://github.com/xonixx/makesure/issues/46) 
3. Improved `./makesure -l` output [#47](https://github.com/xonixx/makesure/issues/47)

## v.0.9.9
1. Improve documentation
2. Improvements/fixes

## v.0.9.8
- `@private` goals [#31](https://github.com/xonixx/makesure/issues/31) 
- `@lib`/`@use_lib` for reuse [#36](https://github.com/xonixx/makesure/issues/36)
- `@goal @glob` redesign [#34](https://github.com/xonixx/makesure/issues/34) 
- improvements/fixes 

## v0.9.7.1
- `@goal_glob`
- improvements/fixes
## v.0.9.6.2
fix for "the input device is not a TTY"
## v.0.9.6
1. Allowed define overrides via `-D`
1. Handled folder for `-f`
1. Made sure it runs on Win under Git bash
1. More fixes
## v.0.9.4
## v.0.9.2
## v.0.9.1
