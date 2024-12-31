{
  sub(/cd .+\/tests/,"cd /some/path/tests") # my dir
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  sub(/echo 'A=aaa'/,"echo A=aaa")
  print >> (/^\+ / ? "/dev/stderr" : "/dev/stdout")
}
