
@options silent

@goal default
@depends_on aaa

@goal aaa
@depends_on bbb
  echo aaa

@goal bbb
@depends_on ccc
  echo bbb

@goal ccc
@depends_on ddd
  echo ccc

@goal ddd
@reached_if true
  echo ddd
