
@goal a
@depends_on b @args '' # empty arg = OK

@goal b @params S
  echo "$S world from b"
