# revamp `@define`

```shell
@define HELLO 'hello'
@define HW    "$HELLO world"
```

## Goals
- Change the syntax to `@define VAR 'value'` to be more consistent
- Adjust semantics & priority
- Interpolate values `@define VAR "hello $WORLD"`
- Be able to setup value on different levels, [see the ansible approach](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)
- Detect unset variable as an error?
- Protect from accidental variable redefinition by environment?
- Keep semantics compatibility with shell?
- Don't introduce new directives or modifiers

## Q. Do we allow default values `@define A="${VAR:-default_val}"`?

- How can we redo current such usages?

## Q. 
        
