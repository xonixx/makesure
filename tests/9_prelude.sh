
# no code allowed in prelude,
# only comments, @define, @shell, @options

@shell bash
@define A=B

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

