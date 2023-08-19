# revamp `@define`

```shell
@define HELLO 'hello'
@define HW    "$HELLO world"
```

## Goals
- Change the syntax to `@define VAR 'value'` to be more consistent
- Be able to implement [#139](https://github.com/xonixx/makesure/issues/139) "Ability to reference `@define`d variables in parameterized dependencies"
  - this requires switching to ad-hoc parsing to be able to get final variable values before goals evaluation
    - Problem: 1-pass parsing may be not enough, because we allow `@define` and `@goal` inter-mixed

## Constraints
- Keep semantics compatibility with shell?
- Don't introduce new directives or modifiers
- Make sure interpolation keeps working `@define VAR "hello $WORLD"`


## Q. Detect unset variable as an error?
## Q. Protect from accidental variable redefinition by environment?


## Q. Adjust semantics & priority

## Q. Be able to setup value on different levels, [see the ansible approach](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)

## Q. Do we allow default values `@define A="${VAR:-default_val}"`?

- How can we redo current such usages?

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
        
