

@goal mydir_1
  cat 2_mydir.txt

@goal mydir_2
  cat ./2_mydir.txt

@goal mydir_3
  cat "$MYDIR/2_mydir.txt"

@goal mydir_in_reached_if_1
@reached_if [[ -f 2_mydir.txt ]]
  echo "should not show"

@goal mydir_in_reached_if_2
@reached_if [[ -f ./2_mydir.txt ]]
  echo "should not show"

@goal mydir_in_reached_if_3
@reached_if [[ -f "$MYDIR/2_mydir.txt" ]]
  echo "should not show"

@goal mydir_in_reached_if_4
@reached_if [[ ! -f 2_mydir.txt ]]
  echo "should show"

@goal mydir_in_reached_if_5
@reached_if [[ ! -f ./2_mydir.txt ]]
  echo "should show"

@goal mydir_in_reached_if_6
@reached_if [[ ! -f "$MYDIR/2_mydir.txt" ]]
  echo "should show"

@goal mydir_in_reached_if_of_dep_1
@depends_on dep_1
  echo "should show"

@goal mydir_in_reached_if_of_dep_2
@depends_on dep_2
  echo "should show"

@goal dep_1
@depends_on dep_3
#@reached_if echo "#$MYDIR#"; [[ -f "$MYDIR/2_mydir.txt" ]]
@reached_if [[ -f "$MYDIR/2_mydir.txt" ]]
  echo "should not show"

@goal dep_2
@depends_on dep_3
#@reached_if echo "#$MYDIR#"; [[ ! -f "$MYDIR/2_mydir.txt" ]]
@reached_if [[ ! -f "$MYDIR/2_mydir.txt" ]]
  echo "should show"

@goal dep_3
  echo dep_3
