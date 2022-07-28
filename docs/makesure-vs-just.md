## `makesure` vs `just` comparison on examples

### Defining dependent vars 

[Problem](https://github.com/casey/just/issues/1292#issuecomment-1197748631)

Makesure doesn't suffer from this issue and has idiomatic solution:

```shell
@lib
  GIT_COMMIT="$(git rev-parse --short HEAD)"
  GIT_TIME="$(git show -s --format=%ci "$GIT_COMMIT" | tr -d '\n')"

@goal default
@use_lib
  echo "$GIT_COMMIT"
  echo "$GIT_TIME"
```