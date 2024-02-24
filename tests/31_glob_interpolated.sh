

@goal g1 @glob "glob_test/*.txt"
  echo "$ITEM"

@define G 'glob_test'

@goal g2 @glob "$G/*.txt"
  echo "$ITEM"

@define G1 "$G/*.txt"

@goal g3 @glob "$G1"
  echo "$ITEM"

