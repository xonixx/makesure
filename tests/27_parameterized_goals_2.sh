
@goal a
@depends_on b @args 'hello'

@goal b @params S @private
@depends_on c @args S
  echo "$S world from b"

@goal c @params S1
  echo "$S1 world from c"

