
@goal b
  echo 'b start'
  sleep 10
  echo 'b - SHOULD NOT SHOW'

@goal a
@depends_on b
  echo 'a - SHOULD NOT SHOW'
