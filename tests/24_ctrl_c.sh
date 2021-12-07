

@goal b
  echo $$ > /tmp/24_ctrl_c.pid
  echo PID1=$$
  echo 'b start'

#  sleep 5 &
#  (
#    kill -INT "$(cat /tmp/24_ctrl_c.pid)"
#  ) &
#  wait

  sleep 100

#  sleep 100 &
#  PID=$!
#  echo PID=$PID
#  wait $PID
  echo 'b - should not show'

@goal a
@depends_on b
  echo 'a - should not show'
