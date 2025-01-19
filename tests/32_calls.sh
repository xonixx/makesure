

@goal 'x-created'
@reached_if test -f /tmp/x
  echo 'running x-created'
  touch /tmp/x

@goal 'x-deleted'
@reached_if ! test -e /tmp/x
  echo 'running x-deleted'
  rm /tmp/x

@goal 'x-updated'
@calls 'x-deleted'
@calls 'x-created'

@goal 'x-updated-1'
@calls 'x-deleted' 'x-created'

@goal a
@calls b
  echo 'a body'

@goal b
  echo 'b body'

@goal gg @glob '11_goal_glob*.txt'
@calls b

@goal pg @params A B
  echo "pg body: $A $B"

@goal c
@calls pg @args 'a_val' 'b_val'
