# Parameterized goals
The idea for this is inspired by [#112](https://github.com/xonixx/makesure/issues/112).
This should be much better and more generic alternative to [#96](https://github.com/xonixx/makesure/issues/96).

This should allow [such rewrite](https://github.com/xonixx/awk_lab/compare/e64437d6199be84bac56bba4d1cfa38ab2f1f5e5...82d272cd0bf01b83f05febe67115c1f59db9b11d#diff-e5d5b21574eca8bd63d8039819c4da3ff78b4c3a2e0a83bc7d406679c5c4f9bf).

Related to [this](https://github.com/xonixx/makesure#omitted-features). Obviously this is being revised.
```shell
@goal files_created @params A B
@depends_on file_created @args $A
@depends_on file_created @args $B
@depends_on file_created @args '/tmp/file'
@depends_on goal_3_args @args $A '/tmp/file' $B

@goal file_created @params F
@reached_if [[ -f "$F" ]]
  echo hello > "$F"
```

## Q. Default values.
No

## Q. Optional values.
No

## Q. How to pass var argument?
- `@VAR`
  - Cons: non-uniform syntax
  - Using this form can help getting rid of `@args` and allow mixing dependencies
  - But this needs to disambiguate the case when goal is named `@name`
- But not that simple… what about literal values?
- `"${VAR}"` but only this form, not `"aaa${VAR} bbb"`
- `VAR`, literal values must be quoted (with single quotes or dollar-single quotes to disallow substitutions)

## Q. Do we even need keyword `@args`?
Looks like we don’t need it to disambiguate. BUT this complicates resolution.

## Q. Do we need keyword `@params`?
Looks like yes
- for consistency
- for ease of parsing

## Q. Do we allow to include parameterized goal in `@depends_on` together with other goals? Or only single?

No. `@args` will be only allowed in pos=3. All items afterwards are considered args.

## Q. Shall we restrict the param name to Name123? `[A-Z][A-Za-z0-9_]*`

This might be good idea / convention.

## Q. Can we make parameterized goals resolution during parsing? We might need to know the number of params for a goal which is not available yet, since goal may come later.

Looks like this is only possible if we restrict the syntax to
```shell
@depends_on param_goal @args 'hello'
```
I.e. when `@args` is at pos=3
```shell
@depends_on param_goal ( 'hello' A 'world' ) # needs more parsing
```
## Q. Allow calling parameterized goal from CLI?

No

## Q. Allow listing PG?
No.
What about “instantiated” goals?

## Q. Loops detection.
Based on goal name only? I.e. disallow depending PG on itself in any way.

## Q. What can be `@args VAR`?
Only:
- what’s in `@define`
- any VAR in `@params` of this goal
  All other cases must cause error.

## Q. Mechanism for "instantiation"

Also here. Need to adjust `-d` option. Should list instantiated goals in form

- `pg1 @args 'hello'`
- `pg2 @args 'hello' $'with \''`
- `nonpg`

1. Build tree no-params : detect loops
2. Build tree non-instantiated
3. Instantiate. How?

On encounter `@depends_on` generate instantiated? But this needs to go in-depth.

## Parameterized goals vs existing features

### PG + @glob
TODO
### PG + @private
TODO
### PG + @lib
TODO
### PG + @reached_if
TODO
### PG + @doc
TODO

# TODOS
- [x] check loop
- [ ] -l in presence of loop hangs
- [ ] check unknown parameterized dep call `@depends_on c @args S`
- [ ] validate param name (regex)
