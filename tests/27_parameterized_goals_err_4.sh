
# TODO all errors at once

@goal a
@depends_on b                    # err missing args
#@depends_on b @args              # err missing args
@depends_on b @args 'hello' 'hi' # err more args than params
@depends_on b @args ARG          # err unknown arg


@goal b @params S
@depends_on c @args S
@depends_on c @args ARG          # err unknown arg
  echo "$S world from b"

@goal c @params S1
  echo "$S1 world from c"