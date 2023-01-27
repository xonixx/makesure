
@goal a
@doc 'doc a'
@depends_on b @args 'hello'

@goal b @params S @private
@doc 'doc b'
@depends_on c @args S
  echo "$S world from b"

@goal c @params S1
@doc 'doc c'
  echo "$S1 world from c"

