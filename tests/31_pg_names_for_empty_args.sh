
@goal @glob 'glob_test/*.txt' @params P Q
  echo "$ITEM $P $Q."

@goal g1
@depends_on 'glob_test/*.txt' @args ''  ''
@depends_on 'glob_test/*.txt' @args 'p' ''
@depends_on 'glob_test/*.txt' @args ''  'q'
@depends_on 'glob_test/*.txt' @args 'p' 'q'