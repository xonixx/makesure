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
  goal 'tests/3_loop.tush' ...
TESTS PASSED : tests/3_loop.tush
  goal 'tests/3_loop.tush' took 0.079 s
  goal 'tests/4_trace.tush' ...
TESTS PASSED : tests/4_trace.tush
  goal 'tests/4_trace.tush' took 0.265 s
  goal 'tests/5_shell.tush' ...
TESTS PASSED : tests/5_shell.tush
  goal 'tests/5_shell.tush' took 0.165 s
  goal 'tests/6_reached_if.tush' ...
TESTS PASSED : tests/6_reached_if.tush
  goal 'tests/6_reached_if.tush' took 0.122 s
  goal 'tests/7_options.tush' ...
TESTS PASSED : tests/7_options.tush
  goal 'tests/7_options.tush' took 0.15 s
  goal 'tests/8_timing.tush' ...
TESTS PASSED : tests/8_timing.tush
  goal 'tests/8_timing.tush' took 0.217 s
  goal 'tests/9_prelude.tush' ...
TESTS PASSED : tests/9_prelude.tush
  goal 'tests/9_prelude.tush' took 0.151 s
  goal 'tests/10_define.tush' ...
TESTS PASSED : tests/10_define.tush
  goal 'tests/10_define.tush' took 0.494 s
  goal 'tests/11_goal_glob.tush' ...
TESTS PASSED : tests/11_goal_glob.tush
  goal 'tests/11_goal_glob.tush' took 0.326 s
  goal 'tests/12_errors.tush' ...
TESTS PASSED : tests/12_errors.tush
  goal 'tests/12_errors.tush' took 0.055 s
  goal 'tests/13_doc.tush' ...
TESTS PASSED : tests/13_doc.tush
  goal 'tests/13_doc.tush' took 0.092 s
  goal 'tests/14_private.tush' ...
TESTS PASSED : tests/14_private.tush
  goal 'tests/14_private.tush' took 0.093 s
  goal 'tests/15_lib.tush' ...
TESTS PASSED : tests/15_lib.tush
  goal 'tests/15_lib.tush' took 0.195 s
  goal 'tests/16_define_validation.tush' ...
TESTS PASSED : tests/16_define_validation.tush
  goal 'tests/16_define_validation.tush' took 0.089 s
  goal 'tests/17_empty_prelude.tush' ...
TESTS PASSED : tests/17_empty_prelude.tush
  goal 'tests/17_empty_prelude.tush' took 0.041 s
  goal 'tests/18_vars_priority.tush' ...
TESTS PASSED : tests/18_vars_priority.tush
  goal 'tests/18_vars_priority.tush' took 0.168 s
  goal 'tests/19_optimize_goals.tush' ...
TESTS PASSED : tests/19_optimize_goals.tush
  goal 'tests/19_optimize_goals.tush' took 0.062 s
  goal 'tests/20_list_goals.tush' ...
TESTS PASSED : tests/20_list_goals.tush
  goal 'tests/20_list_goals.tush' took 0.079 s
  goal 'tests/21_parsing.tush' ...
TESTS PASSED : tests/21_parsing.tush
  goal 'tests/21_parsing.tush' took 0.364 s
  goal 'tests/22_nat_order.tush' ...
TESTS PASSED : tests/22_nat_order.tush
  goal 'tests/22_nat_order.tush' took 0.585 s
  goal 'tests/23_bash_glob.tush' ...
TESTS PASSED : tests/23_bash_glob.tush
  goal 'tests/23_bash_glob.tush' took 0.045 s
  goal 'tests/24_define_everywhere.tush' ...
TESTS PASSED : tests/24_define_everywhere.tush
  goal 'tests/24_define_everywhere.tush' took 0.058 s
  goal 'tests/25_lazy_reached_if.tush' ...
TESTS PASSED : tests/25_lazy_reached_if.tush
  goal 'tests/25_lazy_reached_if.tush' took 0.121 s
  goal 'tests/26_resolved.tush' ...
TESTS PASSED : tests/26_resolved.tush
  goal 'tests/26_resolved.tush' took 0.15 s
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

