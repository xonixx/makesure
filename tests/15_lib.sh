
@define HELLO "Hello"

@lib
  f1 () {
    echo "$HELLO $1"
  }

@goal g1
@use_lib
f1 World

@goal g2
@use_lib lib_name
f2 World

@lib lib_name
  f2 () {
    echo "Hello lib_name $1"
  }

@goal g3
@use_lib
@reached_if [ "$(f1 World)" = "Hello World" ]
echo "Should not see this"

@goal g4
@use_lib lib_name
@reached_if [[ "$(f2 World)" == "123" ]]
echo "Should see this"
