

@goal a
@reached_if echo 'reached_if@a' ; false
@depends_on b
  echo a

@goal b
@reached_if echo 'reached_if@b' ; true
@depends_on c
  echo b

@goal c
@reached_if echo 'reached_if@c' ; false
  echo c

@goal d
  echo d

