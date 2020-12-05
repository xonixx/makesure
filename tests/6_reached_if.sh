
@goal default
@depends_on aaa

@goal aaa
@depends_on bbb
  echo aaa

@goal bbb
@reached_if true
@depends_on ccc ddd
  echo bbb

@goal ccc
@depends_on ddd
  echo ccc

@goal ddd
  echo ddd


