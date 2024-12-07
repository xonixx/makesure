
# @call
       
## Naming: `@call` vs `@calls`

TODO

## Do we allow both `@call` and `@depends_on` on the same level?
                          
```shell
@goal a
@call b
@depends_on c
```

We could but the execution model would be this (`@depends_on` go first):
```shell
@goal a
@depends_on c
"$MAKESURE" b
```

Answer: No, should result in error in the first iteration.

## Do we allow both `@call` and non-empty goal body?

```shell
@goal a
@call b
  echo 'a body'
```

Should be relatively easy.  

## Do we allow `@call goal_name @args 'arg'`?

Let's allow. The goal will be instantiated the same way as for `@depends_on`

What about

```shell
@goal pg1 @params P1 P2
 echo "pg1: $P1 $P2"

@goal pg @params A
@call pg1 @args A "A=$A"
```

Answer: interpolation rules should apply the same as for `@depends_on`, i.e. all works as expected.

## Can we implement it more efficient than just running more makesure processes?

Maybe, but let's do the easiest for the first iteration

## How do we output the dependency tree (`-d`,`--resolved`)

In the first iteration let's not generate a subtree. 

## `@call` operational semantics

Let's implement the simplest strategy of passthrough to `./makesure` invocation

```shell
@goal a
@call b
```

desugars to

```shell
@goal a
"$MAKESURE" [--define ...] b
```

Do we need `--file 'path/to/Makesurefile'`?

No. Even if we run `./makesure path/to/Makesurefile` path resolution is relative to the `Makesurefile` location, so internal makesure invocation now doesn't need explicit Makesurefile reference. But let's add a test for this case.

## the `@define` inheritance

Since we implement this in terms of running the external `./makesure` we need to repeat the variables passed via `-D`.

```shell
@define A 'a'

@define a1
  echo "a1: $A"
  
@define a2
  echo "a2: $A"
  
@define b
@call a1 
@call a2 

@define c
@call a1 a2 
```

desugars to 

```shell
@define A 'a'

@define a1
  echo "a1: $A"
  
@define a2
  echo "a2: $A"
  
@define b
  "$MAKESURE" --define A="$A" a1
  "$MAKESURE" --define A="$A" a2
  
@define c
  "$MAKESURE" --define A="$A" a1
  "$MAKESURE" --define A="$A" a2
```
