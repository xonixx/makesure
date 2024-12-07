
# @calls
       
## Naming: `@call` vs `@calls`

For consistency with `@depends_on` and for better declarativity let's use `@calls`:

```shell
@goal a
@calls b
```

## Do we allow both `@calls` and `@depends_on` on the same level?
                          
```shell
@goal a
@calls b
@depends_on c
```

We could but the execution model would be this (`@depends_on` goes first):
```shell
@goal a
@depends_on c
"$MAKESURE" b
```

Answer: No, should result in error in the first iteration.

## Do we allow both `@calls` and non-empty goal body?

```shell
@goal a
@calls b
  echo 'a body'
```

Should be relatively easy. Don't see any good reason against.

Answer: yes.

## Do we allow `@calls goal_name @args 'arg'`?

Let's allow. The goal will be instantiated the same way as for `@depends_on`

What about

```shell
@goal pg1 @params P1 P2
 echo "pg1: $P1 $P2"

@goal pg @params A
@calls pg1 @args A "A=$A"
```

Answer: interpolation rules should apply the same as for `@depends_on`, i.e. all works as expected.

## Can we implement it more efficient than just running more makesure processes?

Maybe, but let's do the easiest for the first iteration

## How do we output the dependency tree (`-d`,`--resolved`)

In the first iteration let's not generate a subtree. 

## `@calls` operational semantics

Let's implement the simplest strategy of passthrough to `./makesure` invocation

```shell
@goal a
@calls b
```

desugars to

```shell
@goal a
"$MAKESURE" [--define ...] b
```

Do we need `--file 'path/to/Makesurefile'`?

No. Even if we run `./makesure path/to/Makesurefile` path resolution is relative to the `Makesurefile` location, so internal makesure invocation now doesn't need explicit Makesurefile reference. But let's add a test for this case.

Are there other options to passthrough ([Usage](https://makesure.dev/Usage.html))?

Yes:

```
 -s,--silent     silent mode - only output what goals output
 -t,--timing     display execution times for goals and total
 -x,--tracing    enable tracing in bash/sh via `set -x`
```

For `-s` and `-x` it's easy - just replicate.

For `-t` it's trickier, probably we need to find a way to suppress the total time for called goals.

## the `@define` inheritance

Since we implement this in terms of running the external `./makesure` we need to repeat the variables passed via `-D`.

```shell
@define A 'a'

@goal a1
  echo "a1: $A"
  
@goal a2
  echo "a2: $A"
  
@goal b
@calls a1 
@calls a2 

@goal c
@calls a1 a2 
```

desugars to 

```shell
@define A 'a'

@goal a1
  echo "a1: $A"
  
@goal a2
  echo "a2: $A"
  
@goal b
  "$MAKESURE" --define A="$A" a1
  "$MAKESURE" --define A="$A" a2
  
@goal c
  "$MAKESURE" --define A="$A" a1
  "$MAKESURE" --define A="$A" a2
```
