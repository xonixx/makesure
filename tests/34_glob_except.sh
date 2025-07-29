
@goal @glob 'glob/file*.txt' @except 'glob/file_2.txt'
@doc test goal_glob
  echo "$ITEM :: $INDEX :: $TOTAL"
  cat $ITEM

@goal test1
@depends_on 'glob/file_1.txt'
@depends_on 'glob/file_3.txt'

@goal test2
@depends_on 'glob_goal_name@glob/file_2.txt'
@depends_on 'glob_goal_name@glob/file_3.txt'

@goal glob_goal_name @glob 'glob/file*.txt' @except 'glob/file_1.txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@goal glob_goal_name2 @glob 'glob/file*.txt' @except 'glob/file_[12].txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@goal glob_goal_name3 @glob 'glob/file*.txt' @except 'glob/file_1.txt glob/file_2.txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@goal empty_glob @glob '*.txt' @except '*.txt'
  echo 'XXX'
