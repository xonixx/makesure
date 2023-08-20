# revamp `@define`

```shell
@define ENV_VAR              "$ENV_VAR"
@define ENV_VAR_WITH_DEFAULT "${ENV_VAR:-default_val}"
@define HELLO                'hello'
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
    @defile WORLD 'World'
    
    @goal pg @params P
      echo "$P"                        
    
    # should echo only once
    @goal default
    @depends_on pg @args 'Hello World'
    @depends_on pg @args '$HELLO World'
    @depends_on pg @args '$HELLO $WORLD'

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
4. This goes against the default semantics of shell (to treat unset as empty string)

## Q. Protect from accidental variable redefinition by environment?


## Q. Adjust semantics & priority?

## Q. Be able to setup value on different levels, [see the ansible approach](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

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
        
