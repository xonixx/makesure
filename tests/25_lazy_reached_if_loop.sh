

@goal a
@reached_if true
@depends_on b
  echo a

@goal b
@depends_on a
  echo b
