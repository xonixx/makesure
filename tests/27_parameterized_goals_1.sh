
@goal a
@depends_on b @args 'hello'

@goal b @params S
  echo "$S world"
