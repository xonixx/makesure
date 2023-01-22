
@goal a
@depends_on b @args 'hello'

@goal b @params S
@depends_on c @args S
  echo "$S world from b"

@goal c @params S1
@depends_on b @args 'hi'
  echo "$S1 world from c"
