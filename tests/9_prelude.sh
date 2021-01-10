
echo "prelude should execute only once"

@goal a
@depends_on b
  echo a

@goal b
@depends_on c d
  echo b

@goal c
@reached_if true
  echo c

@goal d
@reached_if false
  echo d

