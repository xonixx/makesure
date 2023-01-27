
@goal a
@depends_on greet2 @args 'John' $'\'quoted\''

@goal greet2 @params WHO1 WHO2
@depends_on greet @args WHO1
@depends_on greet @args WHO2

@goal greet @params WHO
  echo "hello $WHO"