@shell sh

@define A=aaa

@goal default
@reached_if [ 1 -eq 2 ]
@depends_on goal1
  echo "A=$A"

@goal goal1
@depends_on goal2
  echo 'goal 1'

@goal goal2
@reached_if true
  echo 'should not show'
