## `makesure` vs `just` comparison on examples

### Defining dependent vars 

[Problem](https://github.com/casey/just/issues/1292#issuecomment-1197748631)

Makesure doesn't suffer from this issue and has idiomatic solution:

```shell
@lib
  GIT_COMMIT="$(git rev-parse --short HEAD)"
  GIT_TIME="$(git show -s --format=%ci $GIT_COMMIT | tr -d '\n')"

@goal default
@use_lib
  echo "$GIT_COMMIT"
  echo "$GIT_TIME"
```

### Comments in recipes are echoed

[Problem](https://github.com/casey/just/issues/1274)

Makesure doesn't echo script lines by default, because it's implementation detail. 

Although it echoes the goal names, such that it's clear what's going on, like so:

```
$ ./makesure
  goal 'tush_installed' [already satisfied].
  goal 'debug' ...
awk: GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
GNU bash, version 5.0.17(1)-release (x86_64-pc-linux-gnu)
  goal 'debug' took 0.012 s
  goal 'prepared4tests' [empty].
  goal 'tests/0_basic.tush' ...
TESTS PASSED : tests/0_basic.tush
  goal 'tests/0_basic.tush' took 0.165 s
  goal 'tests/1_goals.tush' ...
TESTS PASSED : tests/1_goals.tush
  goal 'tests/1_goals.tush' took 0.378 s
  goal 'tests/2_mydir.tush' ...
TESTS PASSED : tests/2_mydir.tush
  goal 'tests/2_mydir.tush' took 0.426 s

...lines omitted...

  goal 'tests/200_update.tush' ...
TESTS PASSED : tests/200_update.tush
  goal 'tests/200_update.tush' took 1.322 s
  goal 'tests/*.tush' [empty].
  goal 'tested' [empty].
  goal 'default' [empty].
  total time 6.475 s
```

### distinction between doc and non-doc comments

[Problem](https://github.com/casey/just/issues/1273)

Makesure doesn't have such issue because it uses own directive for goal description, which doesn't interfere with regular comments:

```shell
# some regular comment
@goal do_it
# some other comment
@doc 'This is very useful goal'
  echo 'Doing...'
```

### need to install

[Problem](https://github.com/casey/just/issues/429#issuecomment-1332682438)

Makesure [doesn't need installation](https://github.com/xonixx/makesure#installation)

