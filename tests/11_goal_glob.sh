
@goal_glob 11_goal_glob*.txt
@doc test goal_glob
  echo "$ITEM :: $INDEX :: $TOTAL"
  cat $ITEM

@goal_glob non-existent-glob*
  echo "wtf"

@goal test1
@depends_on 11_goal_glob_1.txt
@depends_on 11_goal_glob_2.txt
@depends_on 11_goal_glob_3.txt