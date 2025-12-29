
@goal a @glob 'glob_test/1.txt'
  echo "a $ITEM"

@goal b @glob 'glob_test/*.txt'
@depends_on @item a # not all deps are covered by a
  echo "b $ITEM"

@goal notglob
@depends_on @item a
