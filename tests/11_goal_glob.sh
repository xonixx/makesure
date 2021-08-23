
@goal @glob 11_goal_glob*.txt
@reached_if [[ $INDEX -eq 1 ]]
@doc test goal_glob
  echo "$ITEM :: $INDEX :: $TOTAL"
  cat $ITEM

@goal @glob non-existent-glob*
  echo "wtf"

@goal test1
@depends_on 11_goal_glob_1.txt
@depends_on 11_goal_glob_2.txt
@depends_on 11_goal_glob_3.txt

@goal test2
@depends_on goal_name@11_goal_glob_2.txt
@depends_on goal_name@11_goal_glob_3.txt

@goal goal_name @glob 11_goal_glob*.txt
  echo "goal_name ::: $ITEM :: $INDEX :: $TOTAL"
