
# see https://github.com/xonixx/makesure/issues/141

# ERRORS:

@shell "sh"
@options "tracing"

@define "NAME" 'value'

@goal "g1"
@doc "doc"
@depends_on "goal_name"
@depends_on goal_name1 "goal_name"

@goal goal_name
@goal goal_name1

@goal g2 "@private"
@use_lib "lib_name"

@lib "lib_name"

@goal gg1 "@glob" '*.tush'
@goal gg2 @glob   "*.tush" # now OK (since #165)

@goal pg "@params" P

@goal pg1 @params "P"
@depends_on pg "@args" 'value'

# GOOD:

@define NAME1 "value"

@goal pg2 @params A B C

@goal g3
@depends_on pg2 @args "$NAME1" "value" ""