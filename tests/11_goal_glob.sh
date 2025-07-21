
@goal @glob 'glob/file*.txt'
@reached_if [[ $INDEX -eq 1 ]]
@doc test goal_glob
  echo "$ITEM :: $INDEX :: $TOTAL"
  cat $ITEM

@goal @glob 'non-existent-glob*'
  echo "wtf"

@goal test1
@depends_on 'glob/file_1.txt'
@depends_on 'glob/file_2.txt'
@depends_on 'glob/file_3.txt'

@goal test2
@depends_on 'glob_goal_name@glob/file_2.txt'
@depends_on 'glob_goal_name@glob/file_3.txt'

@goal glob_goal_name @glob 'glob/file*.txt'
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"
