

@goal @glob 21_parsing*.txt
  echo "$ITEM"
  cat "$ITEM"

@goal g1 @glob '21_parsing ?.txt'
  echo "$ITEM"
  cat "$ITEM"

@goal test2
@depends_on '21_parsing 2.txt'

@goal test3
@depends_on 'g1@21_parsing 2.txt'
