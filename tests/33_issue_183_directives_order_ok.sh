@goal a
  echo a


@goal b

# comment
@depends_on a
  echo b

@goal c

# comment
@reached_if true

# comment 2
echo c
