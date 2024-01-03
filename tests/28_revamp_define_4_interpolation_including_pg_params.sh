
@define H 'hello'

@goal g
@depends_on pg @args 'world'

@goal pg @params W
@depends_on pg1 @args "$H $W"

@goal pg1 @params V
  echo "$V"