# makesure

[![Run tests](https://github.com/xonixx/makesure/workflows/Run%20tests/badge.svg)](https://github.com/xonixx/makesure/actions?query=workflow%3A%22Run+tests%22)

Simple build tool a-la `make` with declarative goals and dependencies.

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

Now to run the whole build you just issue `makesure` command in a folder with `Makesurefile` (`default` goal will be called). 

You can as well call single goal explicitly, example `makesure built`. 

Also pay attention to `@reached_if` directive. This one allows skipping goal if it's already satisfied. This allows to speedup subsequent executions.

By default, all scripts inside goals are executed with `bash`. If you want to use `sh` just add `@shell sh` directive at start of the `Makesurefile`.  

## Usage

```
$ ./makesure -h
makesure ver. 0.9.7.1
Usage: makesure [options...] [-f buildfile] [goals...]
 -f,--file buildfile
                 set buildfile to use (default Makesurefile)
 -l,--list       list all available goals
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

Since `makesure` is a tiny utility represented by a single file, the recommended installation strategy is to keep it local to a project where it's used. Not only this eliminates the need for repetitive installation for every programmer but also allows using separate `makesure` version per project and update only as needed.

```shell
wget "https://raw.githubusercontent.com/xonixx/makesure/main/makesure_stable?token=$(date +%s)" -Omakesure && \
chmod +x makesure && echo "makesure $(./makesure -v) installed"
```

### Update

Updates `makesure` executable to latest available version in-place:

```shell
./makesure -U
```

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

## Documentation

### Directives

TODO

## Similar tools

- **just** https://github.com/casey/just
  - just is a handy way to save and run project-specific commands
- **Task** https://github.com/go-task/task
  - Task is a task runner / build tool that aims to be simpler and easier to use than, for example, GNU Make.
- **gup** https://github.com/timbertson/gup
  - Gup is a general purpose, recursive, top down software build system.
- **redo** https://github.com/apenwarr/redo
  - redo - a recursive build system. Smaller, easier, more powerful, and more reliable than make.
- **Tup** https://github.com/gittup/tup
  - Tup is a file-based build system for Linux, OSX, and Windows.
- **Please** https://github.com/thought-machine/please
  - Please is a cross-language build system with an emphasis on high performance, extensibility and reproducibility.