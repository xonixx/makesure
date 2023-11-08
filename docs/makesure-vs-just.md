## `makesure` vs `just` comparison on examples

### Defining dependent vars 

[Problem](https://github.com/casey/just/issues/1292#issuecomment-1197748631)

Since Makesure doesn't have its own programming language, it doesn't suffer from this issue and has idiomatic solution:

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

### Distinction between doc and non-doc comments

[Problem](https://github.com/casey/just/issues/1273)

Makesure doesn't have such issue because it uses own directive for goal description, which doesn't interfere with regular comments:

```shell
# some regular comment
@goal do_it
# some other comment
@doc 'This is very useful goal'
  echo 'Doing...'
```

### Need to install

[Problem](https://github.com/casey/just/issues/429#issuecomment-1332682438)

Makesure [doesn't need installation](https://github.com/xonixx/makesure#installation)

### Files as dependency

[Problem](https://github.com/casey/just/issues/867)

[How you do it with makesure](https://github.com/casey/just/issues/867#issuecomment-1344887900)

### Default target doesn't play well with !include

[Problem](https://github.com/casey/just/issues/1557)

By default, `just` invokes the first recipe. Makesure by default invokes the goal named `default`. So, although makesure doesn't have includes, if it had, the issue would not happen.

### `just` can fail to execute shebang-recipes due to 'Permission denied'

[Problem](https://github.com/casey/just/issues/1611)
                                                                         
Makesure doesn't produce temp files during goal execution, so it's not susceptible to this problem.

### Need for custom functions for string manipulation

[Problem](...)
  
Makesure uses shell (instead of own programming language) and relies on shell variables (instead of own kind of variables).

The idiomatic solution to the described problem using [parameterized goals](https://maximullaris.com/parameterized_goals.html):

```shell
@define BUILD_DIR  'build'
@define FILE_NAME  'out'

@goal pandoc @params ARG EXT @private
    echo pandoc input.md -o "$BUILD_DIR/$ARG/$FILE_NAME.$EXT"

@goal html @params ARG
@depends_on pandoc @args ARG 'html'

@goal pdf @params ARG
@depends_on pandoc @args ARG 'pdf'

@goal foo
@depends_on html @args 'foo'
@depends_on pdf  @args 'foo'
```

Calling:
```
$ ./makesure -l
Available goals:
  foo
  html@foo
  pdf@foo

$ ./makesure foo
  goal 'pandoc@foo@html' ...
pandoc input.md -o build/foo/out.html
  goal 'html@foo' [empty].
  goal 'pandoc@foo@pdf' ...
pandoc input.md -o build/foo/out.pdf
  goal 'pdf@foo' [empty].
  goal 'foo' [empty].

$ ./makesure html@foo
  goal 'pandoc@foo@html' ...
pandoc input.md -o build/foo/out.html
  goal 'html@foo' [empty].

```


