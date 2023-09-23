
@define V="V_prelude"

@goal default
  echo "A=$A"
  echo "V=$V"
  sh -c 'echo "in child: A=$A"'
  sh -c 'echo "in child: V=$V"'

@define E="${E:-defaultVal}"

@goal g
  echo "E=$E"