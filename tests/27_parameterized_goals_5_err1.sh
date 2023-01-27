
@goal a
@depends_on b @args   # err missing args

@goal b @params S
  echo "$S world from b"
