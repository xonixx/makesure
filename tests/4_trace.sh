@define A=aaa

@goal default
@reached_if [[ 1 -eq 2 ]]
  echo "A=$A"
