[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner-direct-single.svg)](https://stand-with-ukraine.pp.ua)

# makesure

[![Run tests](https://github.com/xonixx/makesure/workflows/Run%20tests/badge.svg)](https://github.com/xonixx/makesure/actions?query=workflow%3A%22Run+tests%22)
![coverage](coverage.svg)

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

- [Zero-install](#installation)
- [Very portable](#os)
- Very simple, only bare minimum of truly needed features. You don’t need to learn a whole new programming language to use the tool! Literally it’s goals + dependencies + handful of directives + bash/shell.
- Much saner and simpler `make` analog.
- A bunch of useful built-in facilities: timing the goal's execution, listing goals in a build file, a [means](#reached_if) to speed-up repeated builds.
- The syntax of a build file is also a [valid bash/shell](Makesurefile) (though semantics is different). This can to some extent be in use for editing in IDE.

## Usage

```
$ ./makesure -h
makesure ver. 0.9.20
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

```sh
wget "https://raw.githubusercontent.com/xonixx/makesure/main/makesure?token=$(date +%s)" -Omakesure && \
chmod +x makesure && echo "makesure $(./makesure -v) installed"
```
or
```sh
curl "https://raw.githubusercontent.com/xonixx/makesure/main/makesure?token=$(date +%s)" -o makesure && \
chmod +x makesure && echo "makesure $(./makesure -v) installed"
```

### Update

Updates `makesure` executable to latest available version in-place:

```sh
./makesure -U
```

## Prerequisites

### OS    

`makesure` will run on any environment with POSIX shell available. [Tested](https://github.com/xonixx/makesure/actions) and officially supported are:
 
- Linux
- MacOS
- Windows (via Git Bash)
      
## Concepts

- Build file is a text file named `Makesurefile`.
- Build file uses [directives](#directives).
- Build file consists of a set of goals.
- A [goal](#goal) is a labeled piece of shell.
- A goal can declare [dependencies](#depends_on) on other goals. During execution each referenced dependency will run only once despite the number of occurrences in dependency tree. Dependencies will run in proper sequence according to the inferred topological order. Dependency loops will be reported as error.
- Goal bodies are executed in separate shell invocations. It means, you can’t easily pass variables from one goal to another. This is done on purpose to enforce declarative style.
- By default, goals are run with `bash`. You can change to `sh` with `@shell sh` directive specified before all goals.
- For convenience in all shell invocations the current directory is automatically set to the one of `Makesurefile`. Typically, this is the root of the project. This allows using relative paths without bothering of the way the build is run.
- Goal can declare `@reached_if` directive ([link](#reached_if)). This allows skipping goal execution if it's already satisfied.

## Directives
   
### @options

Only valid: in prelude (meaning before any `@goal` declaration).

Valid options: `timing`, `tracing`, `silent`

```
@options timing
```
Will measure and log each goal execution time + total time.

Example `Makesurefile`:
```sh
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

*Small issue exists with this option on macOS.* Due to BSD's `date` not supporting `+%N` formatting option, the default precision of timings is 1 sec. To make it 1 ms precise (if this is important) just install Gawk (`brew install gawk`). In this case Gawk built-in `gettimeofday` function will be used. 
```
@options tracing
```
Will trace the executed shell script. This activates `set -x` shell option under the hood.
```
@options silent
```
By default `makesure` logs the goals being executed. Use this option if this is not desired (you only need the output of your own code in goals).

### @define

Use this directive to declare global variable (visible to all goals).
The variable will be declared as environment variable (via `export`).

Example:

```sh
@define A hello
@define B "${A} world"
@define C 'hello world'
```

This directive is valid [in any place](tests/24_define_everywhere.sh) in `Makesurefile`. However, we recommend:
- place frequently changed variables (like versions) to the top of `Makesurefile`
- place infrequently changed variables closer to the goals/libs that use them

Variable defined with `@define` can be overridden with a variable passed in invocation via `-D` parameter. 

Overall the precedence for variables resolution is (higher priority top):

- `./makesure -D VAR=1`
- `@define VAR 2` in `Makesurefile`
- `VAR=3 ./makesure`

The precedence priorities are designed like this on purpose, to prevent accidental override of `@define VAR='value'` definition in file by the environment variable with the same name. However, sometimes this is the desired behavior. In this case you can use:

```sh
@define VAR  "${VAR}"                      # using the same name, or
@define VAR1 "${ENV_VAR}"                  # using different name, or
@define VAR2 "${VAR_NAME:-default_value}"  # if need the default value when not set  
```

This allows to use environment variables `VAR`, `ENV_VAR`, and `VAR_NAME` to set the value of `VAR`, `VAR1` and `VAR2`. 

Please note, the parser of `makesure` is somewhat stricter here than shell's one:
```sh
@define HW  ${HELLO}world    # makesure won't accept  
@define HW "${HELLO}world"   # OK  
```

### @shell

Only valid: in prelude.

Valid options: `bash` (default), `sh`

Sets the shell interpreter to be used for execution of goal bodies and `@reached_if` conditions.

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

```sh
@goal hello
  echo "Hello world" 
```

Having the above in `Makesurefile` will produce next output when ran with `./makesure hello`
```
hello world
```

Indentation in goal body is optional, unlike `make`, so below is perfectly valid:

```sh
@goal hello
echo "Hello world" 
```

Invoking `./makesure` without arguments will attempt to call the goal named `default`:

```sh
@goal default
  echo "I'm default goal"
```

<ins>Syntax #2:</ins>
```
@goal [ goal_name ] @glob <glob pattern> [ @private ]
```

This one is easy to illustrate with an example:

```sh
@goal process_file @glob '*.txt' 
 echo $ITEM $INDEX $TOTAL
```

Is equivalent to declaring three goals

```sh
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
```sh
@goal @glob '*.txt'
 echo $ITEM $INDEX $TOTAL
```
as equivalent for
```sh
@goal a.txt @private
 echo a.txt 0 2

@goal b.txt @private
 echo b.txt 1 2
 
@goal '*.txt'
@depends_on a.txt 
@depends_on b.txt 
```

So essentially one glob goal declaration expands to multiple goal declarations based on files present in project that match the glob pattern. Shell glob expansion mechanism applies. 

The useful use case here would be to represent a set of test files as a set of goals. The example could be found in the project's own [build file](https://github.com/xonixx/makesure/blob/3be738d771bf855b5a6d3cd08cbc38dc977bed76/Makesurefile#L91).

Why this may be useful? Imagine in your nodejs application you have `test1.js`, `test2.js`, `test3.js`.
Now you can use this `Makesurefile`

```sh
@goal @glob 'test*.js'
  echo "running test file $INDEX out of $TOTAL ..."
  node $ITEM
```

to be able to run each test individually (`./makesure test2.js` for example) and all together (`./makesure 'test*.js'`).

In case if you need to glob the files with spaces in their names, please check the [naming rules section](#naming-rules) below.

### Parameterized goals

Make code easier to reuse.

<ins>Declaration syntax (using `@params`):</ins>
```shell
@goal goal_name @params A B C
```
<ins>Usage syntax (using `@args`):</ins>
```shell
@goal other_goal @params PARAM
@depends_on goal_name @args 'value1' 'value 2' PARAM
```
                           
The idea of using two complementary keywords `@params` + `@args` was inspired by `async` + `await` from JavaScript.

Example:

```shell
@goal file_downloaded @params FILE_NAME
  echo "Downloading $FILE_NAME..."
  
@goal file_processed @params FILE_NAME
@depends_on file_downloaded @args FILE_NAME
  echo "Processing $FILE_NAME..."
  
@goal all_files_processed
@depends_on file_processed @args 'file1' 
@depends_on file_processed @args 'file2' 
@depends_on file_processed @args 'file3' 
```

Having the above in `Makesurefile` will produce next output when ran with `./makesure all_files_processed`:
```
  goal 'file_downloaded@file1' ...
Downloading file1...
  goal 'file_processed@file1' ...
Processing file1...
  goal 'file_downloaded@file2' ...
Downloading file2...
  goal 'file_processed@file2' ...
Processing file2...
  goal 'file_downloaded@file3' ...
Downloading file3...
  goal 'file_processed@file3' ...
Processing file3...
  goal 'all_files_processed' [empty].
```

When listing goals, you'll see "instantiated" goals there:
```
$ ./makesure -l
Available goals:
  all_files_processed
  file_processed@file1
  file_downloaded@file1
  file_processed@file2
  file_downloaded@file2
  file_processed@file3
  file_downloaded@file3
```

And you can even call such "instantiated" goal: 
```
$ ./makesure file_processed@file2
  goal 'file_downloaded@file2' ...
Downloading file2...
  goal 'file_processed@file2' ...
Processing file2...
```

You can also take a look at an [example from a real project](https://github.com/xonixx/intellij-awk/blob/68bd7c5eaa5fefbd7eaa9f5f5a4b77b69dcd8779/Makesurefile#L126).

Note, you can reference the `@define`-ed variables in the arguments of the parameterized goals:

```shell
@define HELLO 'hello'

@goal parameterized_goal @params ARG
  echo "ARG=$ARG"
  
@goal goal1
@depends_on parameterized_goal @args HELLO          # reference by name
@depends_on parameterized_goal @args "$HELLO world" # interpolated inside string
```

Having the above in `Makesurefile` will produce next output when ran with `./makesure goal1`:
```
  goal 'parameterized_goal@hello' ...
ARG=hello
  goal 'parameterized_goal@hello world' ...
ARG=hello world
  goal 'goal1' [empty].
```

Please find a more real-world example [here](https://github.com/xonixx/fhtagn/blob/e7161f92731c13b5afbc09c7d738c1ff4882906f/Makesurefile#L70).

For more technical consideration regarding this feature see [parameterized_goals.md](docs/parameterized_goals.md).

### @doc

Only valid: inside `@goal`.
                  
Provides a description for a goal.

Example `Makesurefile`:

```sh
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
  build : builds the project
  test  : tests the project
```

### @depends_on

Only valid: inside `@goal`.
                 
Syntax:
```
@depends_on goal1 [ goal2 [ goal3 [...] ] ]
```
Declares a dependency on other goal. 

Example `Makesurefile`:

```sh
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

```sh
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

```sh
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

```sh
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

`@reached_if` should only rely on condition that is changed by the owning goal ([why?](https://github.com/xonixx/makesure/issues/105#issuecomment-1031571263)).

### @lib

Syntax:
```
@lib [ lib_name ]
```

Helps with code reuse. Occasionally you need to run similar code in multiple goals. The most obvious approach would be to place a code into `shared.sh` and invoke it in both goals. The downside is that now you need an additional file(s) and the build file is no more self-contained. `@lib` to the resque!

The usage is simple:

```sh
@lib lib_name
  a() { 
    echo Hello $1  
  }

@goal hello_world
@use_lib lib_name
  a World
```

For simplicity can omit name:
       
```sh
@lib
  a() {
    echo Hello $1  
  }

@goal hello_world
@use_lib
  a World
```
     
Operationally `@use_lib` is just substituted by content of a corresponding `@lib`'s body, as if the above goal is declared like:
```sh
@goal hello_world
  a() {
    echo Hello $1  
  }
  a World
```

### @use_lib

Only valid: inside `@goal`.

Only single `@use_lib` per goal is allowed.

### Naming rules

It's *recommended* that you name your goals using alphanumeric chars + underscore. 

However, it's possible to name a goal any way you want provided that you apply proper escaping:

```sh
@goal 'name with spaces' # all chars between '' have literal meaning, same as in shell, ' itself is not allowed in it

@goal $'name that contains \' single quote' # if you need to have ' in a string, use dollar-strings and escape it

@goal usual_name  
```

Now `./makesure -l` gives:
```
Available goals:
  'name with spaces'
  $'name that contains \' single quote'
  usual_name
```

Note, how goal names are already escaped in output. This is to make it easier for you to call it directly:
```sh
./makesure $'name that contains \' single quote'
```

Same naming rules apply to other directives (like `@doc`).

Usually you won't need this escaping tricks often, but they can be especially in use for `@glob` goals if the relevant files have spaces in them:

```sh
@goal @glob 'file\ with\ spaces*.txt'
@goal other
  @depends_on 'file with spaces1.txt'
```

More info on this topic is covered in the [issue](https://github.com/xonixx/makesure/issues/63).
  
## Bash completion
        
Install Bash completion for `./makesure` locally
```shell
[[ ! -f ~/.bash_completion ]] && touch ~/.bash_completion
grep makesure ~/.bash_completion >/dev/null || echo '. ~/.makesure_completion.bash' >> ~/.bash_completion
curl "https://raw.githubusercontent.com/xonixx/makesure/main/completion.bash?token=$(date +%s)" -o ~/.makesure_completion.bash  
echo 'Please reopen the shell to activate completion.'
```

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

- Calling goals with arguments, like in [just](https://github.com/casey/just#recipe-parameters) 
  - We deliberately don't support this feature. The idea is that the build file should be self-contained, so have all the information to run in it, no external arguments should be required. It should be much easier for the final user to run a build. The tool however has limited parameterization capabilities via `./makesure -D VAR=value`.
- Includes
  - This is a considerable complication to the tool. Also, it makes the build file not self-contained.  
- Shells other than `bash`/`sh`
  - Less portable build.
  - If you need to use, say, python for a goal body, it's unclear why you even need `makesure` at all. Besides, you always can just use `python -c "script"`. 
- Custom own programming language, like `make` has
  - We think that this would be unjustified complexity.
  - We believe that the power of shell is enough.
- Parallel execution
  - `makesure` is a task runner, not a full-fledged build tool, like `make`, `ninja` or `bazel`. So if you need one, just use a proper build tool of your choice. 

## Developer notes

Find some contributor instructions in [DEVELOPER.md](docs/DEVELOPER.md).

#### AWK

The core of this tool is implemented in [AWK](https://en.wikipedia.org/wiki/AWK).
Almost all major implementations of AWK will work. Tested and officially supported are [Gawk](https://www.gnu.org/software/gawk/), [BWK](https://github.com/onetrueawk/awk), [mawk](https://invisible-island.net/mawk/). This means that the default AWK implementation in your OS will work.

Developed in [xonixx/intellij-awk](https://github.com/xonixx/intellij-awk).

## Articles

- [Adding parameterized goals to makesure](https://maximullaris.com/parameterized_goals.html) (March 2023)
- [makesure vs make](https://maximullaris.com/makesure-vs-make.html) (March 2023)
- [makesure – make with a human face](https://maximullaris.com/makesure.html) (February 2023)

## Similar tools

- **just** https://github.com/casey/just `Rust`
  - just is a handy way to save and run project-specific commands
- **Taskfile** https://github.com/adriancooney/Taskfile `Bash`
  - A Taskfile is a bash \[...] script that follows a specific format \[...], sits in the root of your project \[...] and contains the tasks to build your project.
- **Task** https://github.com/go-task/task `Go`
  - Task is a task runner / build tool that aims to be simpler and easier to use than, for example, GNU Make.
- **mmake** https://github.com/tj/mmake `Go`
  - Modern Make is a small program which wraps `make` to provide additional functionality
- **Robo** https://github.com/tj/robo `Go`
  - Simple Go / YAML-based task runner for the team
- **haku** https://github.com/VladimirMarkelov/haku `Rust` 
  - A task/command runner inspired by 'make'
- **Invoke-Build** https://github.com/nightroman/Invoke-Build `PowerShell`
  - Build Automation in PowerShell
- **make** https://www.gnu.org/software/make/ `C`
  - \[...] a tool which controls the generation of executables and other non-source files of a program from the program's source files.
