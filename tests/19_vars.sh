
@define V="prelude"

echo "in prelude: A=$A"
echo "in prelude: V=$V"
sh -c 'echo "in prelude: in child: A=$A"'
sh -c 'echo "in prelude: in child: V=$V"'

@goal default
  echo "A=$A"
  echo "V=$V"
  sh -c 'echo "in child: A=$A"'
  sh -c 'echo "in child: V=$V"'