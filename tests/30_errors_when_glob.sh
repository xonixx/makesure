@lib

# should report only 1 error out of repeating due to glob

@goal @glob 'glob_test/*.txt'
@doc 'aaa'
@doc 'bbb'
@reached_if true
@reached_if true
@use_lib
@use_lib
@depends_on @args