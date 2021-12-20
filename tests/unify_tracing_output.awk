{
  sub(ENVIRON["MYDIR"],"/some/path")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  print | (cmd = /^+ / ? "cat >&2" : "cat") # macos doesn't have /dev/std{err,out}
  close(cmd)
}
