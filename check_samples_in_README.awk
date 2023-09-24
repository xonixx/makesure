/^```/ {
  if (InSample = !InSample) { # open
    Sample = ""
  } else { # closed
    checkSample()
  }
  next
}

InSample {
  Sample = Sample $0 "\n"
  next
}

function checkSample(   tmp,out) {
  #  print "\n-------- checking: " Sample
  if (isMakesureSample()) {
#    print "\n------- Makesurefile: " Sample
    print Sample > (tmp = "/tmp/makesuresample1.txt")
    close(tmp)
    if (system("./makesure_dev -f " tmp " -l >" (out="/tmp/makesuresample1_out.txt") " 2>&1") > 0) {
      ErrorsCnt++
      print "\n===== WRONG SYNTAX FOR:"
      print Sample
      print "----- ERROR: "
      system("cat " out)
    }
  }
}
function isMakesureSample() {
  return Sample ~ /(^|\n)@[a-z]+/
}

END { print "Total errors: " ErrorsCnt }