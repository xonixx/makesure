

@goal @glob 22_parsing*.txt
  echo "$ITEM"
  cat "$ITEM"

@goal test2
@depends_on '22_parsing 2.txt'