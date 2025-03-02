{
  sub(/cd .+\/tests/,"cd /some/path/tests") # my dir
  sub(/--file .+\/tests/,"--file /some/path/tests") # my dir
  sub(/\/.+\/makesure(_dev|_candidate)/,"/some/path/makesure_dev")
  sub(/'\['/,"[")
  sub(/'\]'/,"]")
  sub(/echo 'A=aaa'/,"echo A=aaa")
  print >> (/^\+ / ? "/dev/stderr" : "/dev/stdout")
}
