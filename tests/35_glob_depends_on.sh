
@goal a @glob 'glob_test/*.txt'
  echo "a $ITEM"

@goal b @glob 'glob_test/*.txt'
@depends_on @item a
  echo "b $ITEM"

@goal b2 @glob 'glob_test/*.txt'
@calls @item a
@calls @item a
  echo "b2 $ITEM"

@goal @glob 'glob_test/*.txt'
  echo "noname $ITEM"

@goal b3 @glob 'glob_test/*.txt'
@depends_on @item
  echo "b3 $ITEM"

@goal c @glob 'glob_test/*.txt'
@depends_on @item b
  echo "c $ITEM"

@goal a2 @glob 'glob_test/*.txt'
  echo "a2 $ITEM"

@goal d @glob 'glob_test/*.txt'
@depends_on @item a a2
  echo "d $ITEM"

@goal e @glob 'glob_test/*.txt'
@depends_on @item a b
  echo "e $ITEM"

