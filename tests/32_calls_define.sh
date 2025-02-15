
@define A 'A'

@goal a
  echo "a: $A"

@goal b
@calls a
