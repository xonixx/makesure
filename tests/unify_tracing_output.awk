{
  sub(ENVIRON["MYDIR"],"/some/path")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  sub(/echo 'A=aaa'/,"echo A=aaa")
  print >> (/^\+ / ? "/dev/stderr" : "/dev/stdout")
}
