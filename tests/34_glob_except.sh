
@goal @glob '11_goal_glob*.txt' @except '11_goal_glob_2.txt'
@doc test goal_glob
  echo "$ITEM :: $INDEX :: $TOTAL"
  cat $ITEM

@goal test1
@depends_on 11_goal_glob_1.txt
@depends_on 11_goal_glob_2.txt
@depends_on 11_goal_glob_3.txt

@goal test2
@depends_on glob_goal_name@11_goal_glob_2.txt
@depends_on glob_goal_name@11_goal_glob_3.txt

@goal glob_goal_name @glob '11_goal_glob*.txt' @except '11_goal_glob_1.txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@goal glob_goal_name2 @glob '11_goal_glob*.txt' @except '11_goal_glob_[12].txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@goal glob_goal_name3 @glob '11_goal_glob*.txt' @except '11_goal_glob_1.txt 11_goal_glob_2.txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"
