

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