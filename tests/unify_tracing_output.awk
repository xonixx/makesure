{
  sub(ENVIRON["MYDIR"],"/some/path")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  print > (/^+ / ? "/dev/stderr" : "/dev/stdout")
}
