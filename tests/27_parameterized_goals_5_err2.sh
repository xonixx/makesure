
@goal a
@depends_on b         # err missing args

@goal b @params S
  echo "$S world from b"
