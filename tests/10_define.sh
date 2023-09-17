

@define A aaa
@define B "${A}bbb"
@define Commented value # just a comment

@goal testA
echo A=$A

@goal testB
echo B=$B

@goal testC
echo C=$C

@goal testABC
@depends_on testA testB testC

@goal is_not_reached
@depends_on other_goal_2
@reached_if [[ "$A" == "XXX" ]]
  echo "should show"

@goal must_be_reached1
@reached_if [[ "$A" == "aaa" ]]
  echo "should not show"

@goal must_be_reached2
@depends_on other_goal_1
@reached_if [[ "$B" == "aaabbb" ]]
  echo "should not show"

@goal other_goal_1
  echo "other goal 1"

@goal other_goal_2
  echo "other goal 2"

@goal children_reached_or_not
@depends_on must_be_reached1 must_be_reached2 is_not_reached

@goal test_commented_define
  echo "in goal: $Commented"
  sh -c 'echo in child process: $Commented'