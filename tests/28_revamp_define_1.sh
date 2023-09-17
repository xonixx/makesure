
@define VAR 'Value'

@goal pg @params A
  echo "A=$A"

@goal pg2 @params F
@depends_on pg @args F
@depends_on pg @args VAR
@depends_on pg @args 'Str'

@goal g1
@depends_on pg @args VAR

@goal g2
@depends_on pg @args 'Str1'

@goal g3
@depends_on pg2 @args 'Str1'

@goal g4
@depends_on pg2 @args VAR

@goal g5
@depends_on pg2 @args 'Value'

@goal g6
@depends_on pg2 @args 'Str'


