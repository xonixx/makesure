
# @call

## Do we allow both `@call` and `@depends_on` on the same level?

No, should result in error

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
  "$MAKESURE" -D A="$A" a1
  "$MAKESURE" -D A="$A" a2
  
@define c
  "$MAKESURE" -D A="$A" a1
  "$MAKESURE" -D A="$A" a2
```
