

@goal mydir_1
  cat 2_mydir.txt

@goal mydir_2
  cat ./2_mydir.txt

@goal mydir_3
  cat "$MYDIR/2_mydir.txt"

@goal mydir_in_required_if_1
@reached_if [[ -f 2_mydir.txt ]]
  echo "should not show"

@goal mydir_in_required_if_2
@reached_if [[ -f ./2_mydir.txt ]]
  echo "should not show"

@goal mydir_in_required_if_3
@reached_if [[ -f "$MYDIR/2_mydir.txt" ]]
  echo "should not show"

@goal mydir_in_required_if_4
@reached_if [[ ! -f 2_mydir.txt ]]
  echo "should show"

@goal mydir_in_required_if_5
@reached_if [[ ! -f ./2_mydir.txt ]]
  echo "should show"

@goal mydir_in_required_if_6
@reached_if [[ ! -f "$MYDIR/2_mydir.txt" ]]
  echo "should show"
