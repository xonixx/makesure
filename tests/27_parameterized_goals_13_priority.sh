
@goal pg @params P
  echo "P=$P"
  sh -c 'echo in child: P=$P'

@goal a
@depends_on pg @args 'Value'