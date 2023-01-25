
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

@goal f @params                   # zero params is invalid
  echo "f"

@goal f1 @params @private         # zero params is invalid
  echo "f1"

@goal @params A                   # goal without name
  echo "$A"

@goal @params                     # goal without name and zero params
  echo ""

@goal @params @private            # goal without name and zero params
  echo ""

@goal @params @glob '*.txt'       # goal without name
  echo ""

@goal a7 b7 c7 @params D          # wrong goal name / @params in wrong pos
  echo ""

