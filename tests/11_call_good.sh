
@define V="123"

@goal a
@call script1 world

@goal b
@call script1 $V

@goal c
@call script2 $MYDIR

@script script1
  echo "Hello $1"

@script script2
  cat "$1/2_mydir.txt"
