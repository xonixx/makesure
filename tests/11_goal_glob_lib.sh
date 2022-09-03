
@lib
  echo "Unnamed lib ::: $ITEM :: $INDEX :: $TOTAL"

@goal @glob 11_goal_glob*.txt
@use_lib
  echo "@glob       ::: $ITEM :: $INDEX :: $TOTAL"

@goal glob_goal_name @glob 11_goal_glob*.txt
@use_lib lib_name
  echo "glob_goal_name ::: $ITEM :: $INDEX :: $TOTAL"

@lib lib_name
  echo "lib lib_name   ::: $ITEM :: $INDEX :: $TOTAL"
