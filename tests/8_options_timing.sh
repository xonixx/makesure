
@options timing

@goal default
  echo test


@goal reached_goal
@reached_if true
  echo "should not show"

@goal not_reached_goal_1
@reached_if false
  echo "should show 1"

@goal not_reached_goal_2
  echo "should show 2"

@goal empty_goal
@depends_on reached_goal not_reached_goal_1 not_reached_goal_2

