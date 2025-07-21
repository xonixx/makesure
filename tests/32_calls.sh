

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

@goal gg @glob 'glob/file*.txt'
@calls b

@goal a1
  echo 'A1'
@goal a2
  echo 'A2'

@goal aa
@calls a1 a2

@goal g1
  echo 'g1'
@goal g2
  echo 'g2'
@goal ggg
@calls g1 g1
@depends_on g2