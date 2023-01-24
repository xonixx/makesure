
@goal a
@depends_on b @args 'hi'
@depends_on b @args 'hello'
@depends_on b @args 'salut'


@goal b @params W
@reached_if [[ "$W" == 'hello' ]]
  echo "W is $W"