
@goal a
@depends_on b @args ARG1          # err unknown arg


@goal b @params S
@depends_on c @args S
@depends_on c @args ARG2          # err unknown arg
  echo "$S world from b"

@goal c @params S1
  echo "$S1 world from c"