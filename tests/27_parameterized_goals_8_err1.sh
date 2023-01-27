
@goal a
@depends_on c c @args 'hello'
@depends_on @args 'hi'

@goal c
  echo "c"