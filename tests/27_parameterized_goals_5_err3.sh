
@goal a
@depends_on b @args 'hello' 'hi' # err more args than params

@goal b @params S
  echo "$S world from b"
