
@goal a
@depends_on b @args 'hi'
@depends_on b @args 'hello'

@lib
  f() {
    echo "in lib W=$W"
  }

@goal b @params W
@use_lib
  f