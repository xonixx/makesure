@shell sh

@goal default
  echo "$0"

@goal a
@reached_if [ 1 -eq 2 ]
@depends_on b
  echo "should show"

@goal b
@reached_if [ 1 -eq 1 ]
  echo "should not show"
