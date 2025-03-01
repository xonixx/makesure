@goal a
  echo a

@goal b
  echo b
@depends_on a # should be disallowed in this position

@goal c
  echo c

# there was already a (non-empty, non-comment) code line above
@reached_if true # should be disallowed in this position

@goal d
  # comment
  echo d
@doc 'doc' # should be disallowed in this position
