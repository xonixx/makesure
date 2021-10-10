

@goal @glob 21_parsing*.txt
  echo "$ITEM"
  cat "$ITEM"

@goal test2
@depends_on '21_parsing 2.txt'