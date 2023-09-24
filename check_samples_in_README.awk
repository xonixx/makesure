/^```/ {
  if (InSample = !InSample) { # open
    Sample = ""
  } else { # closed
    checkSample()
  }
  next
}

InSample {
  if (!skipLine()) {
    fixLine()
    Sample = Sample $0 "\n"
  }
  next
}
function skipLine() {
  return /makesure won't accept/
}
function fixLine() {
  sub(/\[ @private \]/,"@private")
  sub(/\[ goal_name \]/,"goal_name")
  sub(/\[ lib_name \]/,"lib_name")
  sub("<glob pattern>","'*.*'")
}

function checkSample(   tmp,out) {
  #  print "\n-------- checking: " Sample
  if (isMakesureSample()) {
#    print "\n------- Makesurefile: " Sample
    print Sample > (tmp = "/tmp/makesuresample1.txt")
    close(tmp)
    if (system("./makesure_dev -f " tmp " -l >" (out="/tmp/makesuresample1_out.txt") " 2>&1") > 0) {
      ErrorsCnt++
      print "\n===== PROBLEM WITH SAMPLE:"
      print Sample
      print "----- ERROR: "
      system("cat " out)
    }
  }
}
function isMakesureSample() {
  return Sample ~ /(^|\n)@[a-z]+/
}

END { print "\nTotal errors: " ErrorsCnt }