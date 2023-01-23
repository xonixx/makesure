
# all errors at once

@goal a
@depends_on b                    # err missing args
@depends_on b @args              # err missing args
@depends_on b @args 'hello' 'hi' # err more args than params
@depends_on b @args WRONG1       # err unknown arg
@depends_on e @args 'arg1'       # err args for non-PG
@depends_on unknown1             # err unknown dep
@depends_on unknown2 @args 'arg2' # err unknown dep

@goal b @params S
@depends_on c @args S
@depends_on c @args WRONG2       # err unknown arg
  echo "$S world from b"

@goal c @params S1
@depends_on e @args WRONG3 WRONG4 # multiple errors
  echo "$S1 world from c"

@goal e
  echo "e"