
# testing depending on same PG with different args

@goal a
@depends_on b @args 'hello'
@depends_on b @args 'hi'
@depends_on b @args 'hi hi hi'
@depends_on b @args 'salut'

@goal b @params S
  echo "$S world"

@goal e
@depends_on b @args 'hello'
@depends_on f

@goal f
@depends_on b @args 'hi'
