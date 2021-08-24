

@lib
  f1 () {
    echo "Hello $1"
  }

@lib lib_name
  f2 () {
    echo "Hello lib_name $1"
  }

@goal g1
@use_lib
f1 World

@goal g2
@use_lib lib_name
f1 World
