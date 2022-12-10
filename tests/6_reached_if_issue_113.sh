
@goal g1
@reached_if awk 'BEGIN { exit 0 }'
  echo 'must not show'

@goal g2
@reached_if awk 'BEGIN { exit(1) }'
  echo 'must show'


