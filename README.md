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
- Very simple, only bare minimum of truly needed features. You don’t need to learn a whole new programming language to use the tool! Literally it’s goals + dependencies + handful of directives + bash/shell.
- Much saner and simpler `make` analog.
- A bunch of useful built-in facilities: timing the goal's execution, listing goals in a build file, a [means](#reached_if) to speed-up repeated builds.
- The syntax of a build file is also a valid bash/shell (though semantics is different). This can to some extent be in use for editing in IDE.

## Concepts

- Build file is a text file named `Makesurefile`.
- Build file consists of a prelude and a set of goals.
- Build file uses [directives](#directives). 
- Prelude is a piece of a shell script (can be empty) that goes before goals. The purpose of prelude is to `@define` ([link](#define)) global variables visible to goals. Prelude only runs once.
- A [goal](#goal) is a labeled piece of shell.
- A goal can declare [dependencies](#depends_on) on other goals. During execution each referenced dependency will run only once despite the number of occurrences in dependency tree. Dependencies will run in proper order according to the inferred topological order. Dependency loops will be reported as error.
- Goal bodies are executed in separate shell invocations. It means, you can’t easily pass variables from one goal to another. This is done on purpose to enforce declarative style.
- By default, both prelude and goals are run with `bash`. You can change to `sh` with `@shell sh` in prelude.
- For convenience in all shell invocations (prelude, goals, etc.) the current directory is automatically set to the one of `Makesurefile`. Typically, this is the root of the project. This allows using relative paths without bothering of the way the build is run.
- Goal can declare `@reached_if` directive ([link](#reached_if)). This allows skipping goal execution if it's already satisfied.

## Usage

```
$ ./makesure -h
makesure ver. 0.9.10
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

Since `makesure` is a tiny utility represented by a single file, the recommended installation strategy is to keep it local to a project where it's used (this means in code repository). Not only this eliminates the need for repetitive installation for every dev on a project, but also allows using separate `makesure` version per project and update only as needed.

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
      
#### AWK

The core of this tool is implemented in [AWK](https://en.wikipedia.org/wiki/AWK).
Almost all major implementations of AWK will work. Tested and officially supported are [Gawk](https://www.gnu.org/software/gawk/), [BWK](https://github.com/onetrueawk/awk), [mawk](https://invisible-island.net/mawk/). This means that the default AWK implementation in your OS will work.

The tool will **not** work with Busybox awk.

## Directives
   
### @options

Only valid: in prelude (meaning before any `@goal` declaration).

Valid options: `timing`, `tracing`, `silent`

```
@options timing
```
Will measure and log each goal execution time + total time.

Example `Makesurefile`:
```
@options timing

@goal a
@depends_on b
  echo "Executing goal 'a' ..."
  sleep 1
@goal b
  echo "Executing goal 'b' ..."
  sleep 2
```

Running:
```
$ ./makesure a
  goal 'b' ...
Executing goal 'b' ...
  goal 'b' took 2.003 s
  goal 'a' ...
Executing goal 'a' ...
  goal 'a' took 1.003 s
  total time 3.006 s
```

*Small issue exists with this option on macOS.* Due to BSD `date` not supporting `+%N` formatting option the default precision of timings is 1 sec. To make it 1 ms precise (if this is important) just install Gawk (`brew install gawk`). In this case Gawk built-in `gettimeofday` function will be used. 
```
@options tracing
```
Will trace the executed shell script. This activates `set -x` shell option under the hood.
```
@options silent
```
By default `makesure` logs the goals being executed. Use this option if this is not desired (you only need the output of your own code in goals).

### @define

Only valid: in prelude.

Use this directive to declare global variable (visible to all goals).
The variable will be declared as environment variable (via `export`).

Example:

```
@define A=hello
@define B="${A} world"
```

Variable defined with `@define` can be overridden with a variable passed in invocation via `-D` parameter. 

Overall the precedence for variables resolution is (higher priority top):

- `./makesure -D VAR=1`
- `@define VAR=2` in `Makesurefile`
- `VAR=3 ./makesure`


### @shell

Only valid: in prelude.

Valid options: `bash` (default), `sh`

Sets the shell interpreter to be used for execution of prelude and goals.

Example:

```
@shell sh
```

### @goal

<ins>Syntax #1:</ins>
```
@goal goal_name [ @private ]
```

Defines a goal. `@private` modifier is optional. When goal is private, it won't show in `./makesure -l`. To list all goals including private use `./makesure -la`.

Lines that go after this declaration line (but before next `@goal` declaration line) will be treated as a shell script for the body of the goal. Example:

```
@goal hello
  echo "Hello world" 
```

Having the above in `Makesurefile` will produce next output when ran with `./makesure hello`
```
hello world
```

Indentation in goal body is optional, unlike `make`, so below is perfectly valid:

```
@goal hello
echo "Hello world" 
```

Invoking `./makesure` without arguments will attempt to call the goal named `default`:

```
@goal default
  echo "I'm default goal"
```

<ins>Syntax #2:</ins>
```
@goal [ goal_name ] @glob <glob pattern> [ @private ]
```

This one is easy to illustrate with an example:

```
@goal process_file @glob *.txt 
 echo $ITEM $INDEX $TOTAL
```

Is equivalent to declaring three goals

```
@goal process_file@a.txt @private
 echo a.txt 0 2

@goal process_file@b.txt @private
 echo b.txt 1 2
 
@goal process_file
@depends_on process_file@a.txt   
@depends_on process_file@b.txt   
```
iff
```
$ ls
a.txt b.txt
```

For convenience, you can omit name in case of glob goal:
```
@goal @glob *.txt
 echo $ITEM $INDEX $TOTAL
```
as equivalent for
```
@goal a.txt @private
 echo a.txt 0 2

@goal b.txt @private
 echo b.txt 1 2
 
@goal *.txt
@depends_on a.txt 
@depends_on b.txt 
```

So essentially one glob goal declaration expands to multiple goal declarations based on files present in project that match the glob pattern. Shell glob expansion mechanism applies. 

The useful use case here would be to represent a set of test files as a set of goals. The example could be found in the project's own [build file](https://github.com/xonixx/makesure/blob/main/Makesurefile#L98).

Why this may be useful? Imagine in your nodejs application you have `test1.js`, `test2.js`, `test3.js`.
Now you can use this `Makesurefile`

```
@goal @glob test*.js
  echo "running test file $INDEX out of $TOTAL ..."
  node $ITEM
```

to be able to run each test individually (`./makesure test2.js` for example) and all together (`./makesure 'test*.js'`). 

### @doc

Only valid: inside `@goal`.
                  
Provides a description for a goal.

Example `Makesurefile`:

```
@goal build
@doc builds the project 
  echo "Building ..."
  
@goal test
@doc tests the project
  echo "Testing ..."
```

Running `./makesure -l` will show

```
Available goals:
  build - builds the project
  test - tests the project 
```

### @depends_on

Only valid: inside `@goal`.

Declares a dependency on other goal. 

Example `Makesurefile`:

```
@goal a
  echo a
  
@goal b
@depends_on a
  echo b
```

Running `./makesure b` will show
 
```
  goal 'a' ...
a
  goal 'b' ...
b
```

You can declare multiple dependencies for a goal:

```
@goal a
  echo a

@goal b
@depends_on a
  echo b

@goal c
  echo c

@goal d
@depends_on b c
  echo d
```

Running `./makesure d` will show
```
  goal 'a' ...
a
  goal 'b' ...
b
  goal 'c' ...
c
  goal 'd' ...
d
```

Circular dependency will cause an error:

```
@goal a
@depends_on b

@goal b
@depends_on c

@goal c
@depends_on a
```

Running `./makesure a` will show
```
There is a loop in goal dependencies via a -> c
```

### @reached_if

Only valid: inside `@goal`.
     
Syntax:
```
@reached_if <condition>
```

Allows skipping goal execution if it's already satisfied. This allows to speedup subsequent executions. Only one per goal allowed. The goal will be considered fulfilled (and thus will not run) if `condition` executed as a shell script returns exit code `0`. Any `condition` evaluation is done only once.

Example `Makesurefile`:

```
@goal file_created
@reached_if [[ -f ./file.txt ]]
  echo "Creating file ..."
  echo "hello world" > ./file.txt
```

If you run `./makesure file_created` the first time:
```
  goal 'file_created' ...
Creating file ...
```

If you run `./makesure file_created` the second time:
```
  goal 'file_created' [already satisfied].
```

It is a good practice to name goals that declare `@reached_if` in past tense.

### @lib

Syntax:
```
@lib [ lib_name ]
```

Helps with code reuse. Occasionally you need to run similar code in multiple goals. The most obvious approach would be to place a code into `shared.sh` and invoke it in both goals. The downside is that now you need an additional file(s) and the build file is no more self-contained. `@lib` to the resque!

The usage is simple:

```
@lib lib_name
  a() { 
    echo Hello $1  
  }

@goal hello_world
@use_lib lib_name
  a World
```

For simplicity can omit name:
       
```
@lib
  a() {
    echo Hello $1  
  }

@goal hello_world
@use_lib
  a World
```
     
Operationally `@use_lib` is just substituted by content of a corresponding `@lib`'s body, as if the above goal is declared like:
```
@goal hello_world
  a() {
    echo Hello $1  
  }
  a World
```

### @use_lib

Only valid: inside `@goal`.

Only single `@use_lib` per goal is allowed. 

## Design principles

- Convention over configuration.
- Minimalistic. Bare minimum of features that compose good with each other.
- There should be one way to do the thing.
- Overall [Zen of Python](https://www.python.org/dev/peps/pep-0020/#the-zen-of-python).
- Think hard before adding new feature. Think of a damage it could cause used improperly. Think of cognitive complexity it introduces. Only add a feature generic enough to cover lots of useful cases instead of just some corner cases. Let's better have a list of recipes for the latter.
- Do not introduce unjustified complexity. User should not be forced to learn a whole new programming language to work with a tool. Instead, the tool is based on limited set of simple concepts, like goals + dependencies + handful of directives + familiar shell language (bash/sh).
- [Worse is better](https://en.wikipedia.org/wiki/Worse_is_better).
- [Principle of least surprise](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).
- Tests coverage is a must.

## Omitted features

- Goals with parameters, like in [just](https://github.com/casey/just#recipe-parameters) 
  - We deliberately don't support this feature. The idea is that the build file should be self-contained, so have all the information to run in it, no external parameters should be required. This should be much easier for the final user to run a build. The other reason is that the idea of goal parameterization doesn't play well with dependencies. The tool however has limited parameterization capabilities via `./makesure -D VAR=value`.
- Includes
  - This is a considerable complication to the tool. Also, it makes the build file not self-contained.  
- Shells other than `bash`/`sh`
  - Less portable build.
  - If you need to use, say, python for a goal body, it's unclear why you even need `makesure` at all. Besides, you always can just use `python -c "script"`. 
- Custom own programming language, like `make` has
  - We think that this would be unjustified complexity.
  - We believe that the power of shell is enough.
- parallel execution
  - `makesure` is a task runner, not a full-fledged build tool, like `make`, `ninja` or `bazel`. So if you need one, just use a proper build tool of your choice. 

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
