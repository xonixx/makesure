
@goal a
@depends_on b @args 'hello'

@goal b @params S
@depends_on c @args S

@goal c @params S1
  echo "$S1 world"

