
@define H 'hello'

@goal g
@depends_on pg @args 'world'

@goal pg @params V
@depends_on pg1 @args "$H $V"

@goal pg1 @params V
  echo "$V"