
@goal a @glob 'glob_test/*.txt'
  echo "a $ITEM"

@goal b @glob 'glob_test/*.txt'
@depends_on a @item
  echo "b $ITEM"

@goal b2 @glob 'glob_test/*.txt'
@calls a @item
@calls a @item
  echo "b2 $ITEM"
