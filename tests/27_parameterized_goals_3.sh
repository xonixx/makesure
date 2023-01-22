
# testing dependency run-once semantics

@goal a
@depends_on b @args 'hello'
@depends_on b @args 'hello'
@depends_on b @args 'hello'

@goal b @params S
  echo "$S world"

@goal e
@depends_on b @args 'hello'
@depends_on f

@goal f
@depends_on b @args 'hello'
