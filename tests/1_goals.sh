
@goal default
@depends_on aaa

@goal aaa
@doc Documenatation for aaa
@depends_on bbb
  echo aaa

@goal bbb
@doc Documenatation for bbb line 1
@doc Documenatation for bbb line 2
@reached_if true
@depends_on ccc ddd
  echo bbb

@goal ccc
@depends_on ddd
  echo ccc

@goal ddd
  echo ddd

@goal fail
  echo stdout
  echo >&2 stderr
  exit 1


