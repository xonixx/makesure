
@goal default
@depends_on aaa

@goal aaa
@doc Documenatation for aaa
@depends_on bbb
  echo aaa

@goal bbb
@doc Documenatation for bbb
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

@goal fail123
  echo stdout
  echo >&2 stderr
  exit 123

@goal good-name # should not cause error
