
@define A=a

@goal default
@use_lib
  echo "$A"
  f
  echo "$C"

@define B="${A}b"

@lib
  f() {
    echo "$B"
  }

@define C="${B}c"
