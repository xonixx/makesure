
@goal a @glob 'glob_test/*.txt'
  echo "a $ITEM"

@goal b @glob 'glob_test/*.txt'
@depends_on a @item
  echo "b $ITEM"

@goal b2 @glob 'glob_test/*.txt'
@calls a @item
@calls a @item
  echo "b2 $ITEM"

@goal @glob 'glob_test/*.txt'
  echo "noname $ITEM"

@goal b3 @glob 'glob_test/*.txt'
@depends_on @item
  echo "b3 $ITEM"

@goal c @glob 'glob_test/*.txt'
@depends_on b @item
  echo "c $ITEM"

