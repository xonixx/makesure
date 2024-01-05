
@goal @glob 'glob_test/*.txt' @params P
  echo "$ITEM $P"

@goal g1
@depends_on 'glob_test/*.txt' @args 'hello'

@goal g2
@depends_on 'glob_test/*.txt' @args 'hello'
@depends_on 'glob_test/*.txt' @args 'hi'

@goal g3
@depends_on g3pg @args 'salut'

@goal g3pg @params X
@depends_on 'glob_test/*.txt' @args X
