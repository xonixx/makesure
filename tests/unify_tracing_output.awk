{
  sub(ENVIRON["MYDIR"],"/some/path")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  sub(/echo 'A=aaa'/,"echo A=aaa")
  print | (/^\+ / ? "cat >&2" : "cat") # macos doesn't have /dev/std{err,out}
}
