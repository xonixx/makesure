# revamp `@define`

```shell
@define ENV_VAR              "$ENV_VAR"
@define ENV_VAR_WITH_DEFAULT "${ENV_VAR:-default_val}"
@define HELLO                'hello'
@define HELLO1               $'hello'
@define HW                   "$HELLO world"
```

## Goals
- Change the syntax to `@define VAR 'value'` to be more consistent (current `@define VAR='value'`)
- Be able to implement [#139](https://github.com/xonixx/makesure/issues/139) "Ability to reference `@define`d variables in parameterized dependencies"
  - this requires switching to ad-hoc parsing to be able to get final variable values before goals evaluation
    - Problem: 1-pass parsing may be not enough, because we allow `@define` and `@goal` inter-mixed (since [#95](https://github.com/xonixx/makesure/issues/95))

## Constraints
- Keep semantics compatibility with shell
- It's desirable to not introduce new directives or modifiers
- Make sure interpolation keeps working `@define VAR "hello $WORLD"`
- Make sure run-once semantics is not violated:
  - ```shell
    @defile HELLO 'Hello'
    @defile WORLD 'world'
    
    @goal pg @params P
      echo "$P"                        
    
    # should echo only once
    @goal default
    @depends_on pg @args 'Hello world'
    @depends_on pg @args "$HELLO world"
    @depends_on pg @args "$HELLO $WORLD"
 
## Q. What about mixing parameterized goal param with `@define` var?

### Analysis
   
If we support this it means 
- we need to defer `"String with $VAR"` parsing for `@args` till the instantiation.
- we need to support parsing + variables substitution as separate step.

```shell
@define VAR 'world'

@goal pg1 @params P
  echo "$P"

@goal pg2 @params X
@depends_on pg1 @args "$X $VAR"  

@goal default
@depends_on pg2 @args "Hello"
# should output 'Hello world'
```

### Resolution

We won't support interpolation for `@args` values. That is we only support:

```shell
@define VAR 'value'

@goal pg1 PARAM
@depends_on pg2 @args PARAM VAR 'literal1' $'literal2' 
```

## Q. Detect unset variable as an error?
    
### Cons
        
1. Custom check gives more fine-grained error                                                         
```shell
@goal env_is_set @private
@reached_if [[ -n "$ENV" ]]
  >&2 echo "ENV is not set, please use -D ENV=test or -D ENV=prod"
  exit 1
```

2. Worse is better violation
3. Maybe have modifier `@required` instead?
4. _This goes against the default semantics of shell (to treat unset as empty string)_

### Resolution

- we will not error
- we will resolve to empty string

## Q. Protect from accidental variable redefinition by environment?
 
We will not change the current resolution priority. It has sufficient protection from accidental redefinition, because `@define A 'value'` have priority over environment variable `A`.

## Q. Adjust semantics & priority?

No, see above.

## Q. Be able to setup value on different levels, [see the ansible approach](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

We are not changing the priorities or adding new ways to define a variable.

## Q. Can we disallow default values `@define A="${VAR:-default_val}"`?

How can we redo current such usages?

If we want to allow `@define A='default_val'` instead of `@define A="${A:-default_val}"` we need to adjust the **current** priorities (higher priority top):

- `./makesure -D VAR=1`
- `@define VAR=2` in `Makesurefile`
- `VAR=3 ./makesure`

**updated**:

- `./makesure -D VAR=1`
- `VAR=3 ./makesure`
- `@define VAR=2` in `Makesurefile`

### Cons

Now we open the door for accidental env variable clash to override the value.
The explicit way of `@define A="${A:-default_val}` is safer. Say, if it clashes, just change to `@define A="${A_THAT_DONT_CLASH:-default_val}`.

### Resolution

No, we won't disallow.


## Q. Be able to set variable globally (via environment, not cli)

Now this is achieved by 

```shell
# Makesurefile

@define VAR="${VAR}"

@goa default
  echo "$VAR"
```

```
$ export VAR=hello
$ ./makesure 
```

## Q. How do we know when to parse with `'`/`$'`/`"` - quoted strings or unquoted?
                    
Need to come up with the simplest approach to parse and error on wrong quoting of particular word.

Lets define string quoting types:

- `u` for `string`
- `'` for `'string'`
- `$` for `$'string'`
- `"` for `"string"`


We need to parse two cases separately

- `@define VAR "value"`
  - allowing only unquoted in 1st and 2nd position and any quote in 3rd
- All others re-parsed cases like 
  - `@goal $'goal name' @params A B @private`
    - `u'$` in 2nd, `u` in all other pos
  - `@depends_on $'goal name' 'goal name2'`
    - `u'$` in 2+ pos
  - `@depends_on $'goal name' @args A 'literal' $'literal2'`
    - `u'$` in 2nd, `u'$` in 4+
        
