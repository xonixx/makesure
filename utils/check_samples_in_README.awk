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
  sub(/\[ @except <except pattern> \]/,"@except '*.txt'")
  sub("<glob pattern>","'*.*'")
  sub("<condition>","true")
  sub(/\[ goal2 \[ goal3.+]/,"goal2 goal3\n")
}

function checkSample(   tmp,out) {
  #  print "\n-------- checking: " Sample
  if (isMakesureSample()) {
    Samples++
    fixSample()
#    print "\n------- Makesurefile: " Sample
    print Sample > (tmp = "/tmp/makesuresample1.txt")
    close(tmp)
    if (system("./makesure_dev -f " tmp " -l >" (out="/tmp/makesuresample1_out.txt") " 2>&1") > 0 && !isExpectedError(out)) {
      ErrorsCnt++
      print "\n===== PROBLEM WITH SAMPLE:"
      print Sample
      print "----- ERROR: "
      system("cat " out)
    }
  }
}
function isExpectedError(out,   s,l) {
  (s = ("cat " out)) | getline l
  close(s)
  return l == "There is a loop in goal dependencies via a -> c"
}
function fixSample() {
  if (Sample ~ /@reached_if/) {
    Sample = "@goal g\n" Sample
  } else if (Sample ~ /@depends_on goal_name @args/) {
    Sample = "@goal goal_name @params A B C\n" Sample
  } else if (Sample ~ /@(depends_on|calls) goal1 goal2 goal3/) {
    Sample = "@goal goal1\n@goal goal2\n@goal goal3\n@goal goal\n" Sample
  } else if (Sample ~ /@calls b/) {
    Sample = "@goal b\n@goal c\n@goal d\n" Sample
  }
}

function isMakesureSample() {
  return Sample ~ /(^|\n)@[a-z]+/
}

BEGIN { system("touch '/tmp/file with spaces1.txt'") }
END {
  print "\nTotal samples: " (+Samples)
  print "Total errors : " (+ErrorsCnt)
  exit ErrorsCnt > 0
}