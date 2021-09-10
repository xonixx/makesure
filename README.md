# makesure

[![Run tests](https://github.com/xonixx/makesure/workflows/Run%20tests/badge.svg)](https://github.com/xonixx/makesure/actions?query=workflow%3A%22Run+tests%22)

Simple task/command runner inspired by `make` with declarative goals and dependencies.

The simplest way to think of this tool is to have a way to have "shortcuts" (aka goals) to some pieces of scripts. This way allows to call them easily without the need to call long shell one-liners instead.

Example `Makesurefile`:

```
@goal downloaded
@reached_if [[ -f code.tar.gz ]]
  wget http://domain/code.tar.gz
  
@goal extracted
@depends_on downloaded
  tar xzf code.tar.gz 

@goal built
@depends_on extracted
  npm install
  npm run build

@goal deployed
@depends_on built
  scp -C -r build/* user@domain:~/www

@goal default
@depends_on deployed
```

Now to run the whole build you just issue `./makesure` command in a folder with `Makesurefile` (`default` goal will be called). 

You can as well call single goal explicitly, example `./makesure built`. 

Also pay attention to `@reached_if` directive. This one allows skipping goal if it's already satisfied. This allows to speedup subsequent executions.

By default, all scripts inside goals are executed with `bash`. If you want to use `sh` just add `@shell sh` directive at start of the `Makesurefile`.  

## Features

- [Zero-install](#installation).
- [Very portable](#os).
- Very simple, only bare minimum of truly needed features. You don’t need to learn a whole new programming language to use the tool! Literally it’s goals + dependencies + bash/shell.
- Much saner and simpler `make` analog.
- A bunch of useful built-in facilities: timing the goal's execution, listing goals in a build file, a means to speed-up repeated builds (link to @reached_if).
- The syntax of a build file is also a valid bash/shell (though semantics is different). This can to some extent be in use for editing in IDE.

## Concepts

- Build file is a text file named `Makesurefile`.
- Build file consists of a prelude and a set of goals.
- Prelude is a piece of a shell script (can be empty) that goes before goals and can `@define` (Link) global variables visible to goals. Prelude only runs once.
- A goal is a labeled piece of shell (link).
- A goal can declare dependencies on other goals (link). During execution each referenced dependency will run only once despite the number of occurrences in dependency tree. Dependencies will run in proper order according to the inferred topological order. Dependency loops will be reported as error.
- Goal bodies are executed in separate shell invocations. It means, you can’t easily pass variables from one goal to another. This is done on purpose to enforce declarative style.
- By default, both prelude and goals are run with `bash`. You can change to `sh` with `@shell sh` in prelude.
- For convenience in all shell invocations (prelude, goals, etc.) the current directory is automatically set to the one of `Makesurefile`. Typically, this is the root of the project. This allows using relative paths without bothering of the way the build is run.
- Goal can declare `@reached_if condition` directive (link). Only one per goal allowed. The goal will be considered fulfilled (and thus will not run) if `condition` executed as a shell script returns exit code `0`. Any `@reached_if condition` evaluation is done only once.

## Usage

```
$ ./makesure -h
makesure ver. 0.9.8
Usage: makesure [options...] [-f buildfile] [goals...]
 -f,--file buildfile
                 set buildfile to use (default Makesurefile)
 -l,--list       list all available non-@private goals
 -la,--list-all  list all available goals
 -d,--resolved   list resolved dependencies to reach given goals
 -D "var=val",--define "var=val"
                 override @define values
 -s,--silent     silent mode - only output what goals output
 -t,--timing     display execution times for goals and total
 -x,--tracing    enable tracing in bash/sh via `set -x`
 -v,--version    print version and exit
 -h,--help       print help and exit
 -U,--selfupdate update makesure to latest version
```

## Installation

Since `makesure` is a tiny utility represented by a single file, the recommended installation strategy is to keep it local to a project where it's used (this means in code repository). Not only this eliminates the need for repetitive installation for every programmer, but also allows using separate `makesure` version per project and update only as needed.

```shell
wget "https://raw.githubusercontent.com/xonixx/makesure/main/makesure_stable?token=$(date +%s)" -Omakesure && \
chmod +x makesure && echo "makesure $(./makesure -v) installed"
```

### Update

Updates `makesure` executable to latest available version in-place:

```shell
./makesure -U
```

## Prerequisites

### OS    

`makesure` will run on any environment with Posix shell available. [Tested](https://github.com/xonixx/makesure/actions) and officially supported are:
 
- Linux
- MacOS
- Windows (via Git Bash)
      
### AWK

The core of this tool is implemented in [AWK](https://en.wikipedia.org/wiki/AWK).
Almost all major implementations of AWK will work. Tested and officially supported are:

- [Gawk](https://www.gnu.org/software/gawk/)
- [BWK](https://github.com/onetrueawk/awk)
- [mawk](https://invisible-island.net/mawk/)

This means that the default AWK implementation in your OS will work.

The tool will **not** work with Busybox awk.

## Design principles

- Convention over configuration.
- Minimalistic. Bare minimum of features that compose good with each other.
- There should be one way to do the thing.
- Overall [Zen of Python](https://www.python.org/dev/peps/pep-0020/#the-zen-of-python). 
- Think hard before adding new feature. Think of a damage it could cause used improperly. Think of cognitive complexity it introduces. Only add a feature generic enough to cover lots of useful cases instead of just some corner cases. Let's better have a list of recipes for the latter.
- Do not introduce unjustified complexity. User should not be forced to learn a whole new programming language to work with a tool. Instead, the tool is based on limited set of simple concepts, like goals + dependencies + @reached_if + familiar shell language (bash/sh).
- [Worse is better](https://en.wikipedia.org/wiki/Worse_is_better).
- [Principle of least surprise](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).
- Tests coverage is a must.

## Omitted features
- goals with arguments (like in just). We deliberately don’t support this feature. The idea is that the build file should be self-contained, so have all the information to run in it, no external parameters should be required. This should be much easier for the final user to run a build. The other reason is that the idea of goal parameterization doesn't play well with dependencies. The tool however has limited parameterization capabilities via -D (link).
- Includes TODO
- shells other from bash/sh TODO
- Custom programming language TODO
- parallel execution TODO

## Documentation

### Directives
   
#### @options

Only valid: in prelude.

Valid options: `timing`, `tracing`, `silent`

```
@options timing
```
Will measure and log each goal execution time + total time. 
```
@options tracing
```
Will trace the executed shell script. This activates `set -x` shell option under the hood.
```
@options silent
```
By default `makesure` logs the goals being executed. Use this option if this is not desired (you only need the output of your own code in goals).

#### @define

Only valid: in prelude.

Use this directive to declare global variable (visible to all goals).
The variable will be declared as environment variable (via `export`).

Example:

```
@define A=hello
@define B="${A} world"
```

#### @shell

Only valid: in prelude.

Valid options: `bash` (default), `sh`

Sets the shell interpreter to be used for execution of prelude and goals.

Example:

```
@shell sh
```

#### @goal

#### @doc

#### @depends_on

#### @reached_if

#### @lib

#### @use_lib

## Similar tools

- **just** https://github.com/casey/just
  - just is a handy way to save and run project-specific commands
- **Task** https://github.com/go-task/task
  - Task is a task runner / build tool that aims to be simpler and easier to use than, for example, GNU Make.
- **haku** https://github.com/VladimirMarkelov/haku
  - A task/command runner inspired by 'make'
- **gup** https://github.com/timbertson/gup
  - Gup is a general purpose, recursive, top down software build system.
- **redo** https://github.com/apenwarr/redo
  - redo - a recursive build system. Smaller, easier, more powerful, and more reliable than make.
- **Tup** https://github.com/gittup/tup
  - Tup is a file-based build system for Linux, OSX, and Windows.
- **Please** https://github.com/thought-machine/please
  - Please is a cross-language build system with an emphasis on high performance, extensibility and reproducibility.
