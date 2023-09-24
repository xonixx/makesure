
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

@goal g7
@depends_on pg @args "the $VAR"

@define V1 1.2.3
@define V2 email@example.com
@define V3 "${UNSET:-default\\\}\$\"}"
@define V4 "${UNSET:-}"

@goal g8
echo "$V1 ${V2} ${V3}${V4}"
