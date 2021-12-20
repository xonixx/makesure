{
  sub(ENVIRON["MYDIR"],"/some/path")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  print | (/^+ / ? "cat >&2" : "cat") # macos doesn't have /dev/std{err,out}
}
