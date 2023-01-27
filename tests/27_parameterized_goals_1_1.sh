
# testing dependency run-once semantics

@goal b @params S
  echo "$S world"

@goal e
@depends_on f

@goal f
@depends_on b @args 'hello'
