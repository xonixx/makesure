
set timeout 1
set completionScript [ file normalize "../../completion.bash" ]

proc checkCompletion { exe flagPrefix expectedFlag } {
    global completionScript
    spawn env PS1=bash#\  bash --norc
    sleep 0.01
    send " . $completionScript\r"
    send " $exe $flagPrefix\t"

    expect {
        "$expectedFlag" { puts "\nSUCCESS" }
        timeout { puts "\nERROR"; exit 1 }
    }
}

checkCompletion "./makesure" "--sel" "selfupdate"
checkCompletion "./makesure" "--res" "resolved"

checkCompletion "./makesure" "goal" "goalAaa"
checkCompletion "./makesure" "-f Makesurefile.txt goal" "goalBbb"
checkCompletion "./makesure" "--file 'Makesurefile with spaces.txt' goal" "goalCcc"
checkCompletion "./makesure" "--file Makesurefile\\ with\\ spaces.txt goal" "goalCcc"

checkCompletion "./makesure" "-f Makesurefile.t" "Makesurefile.txt"
checkCompletion "./makesure" "-f ./Makesurefile.t" "Makesurefile.txt"
checkCompletion "./makesure" "--file Makesurefile.t" "Makesurefile.txt"

checkCompletion "./makesure" "--file Makesurefile\\ w" "spaces.txt"

cd dir

checkCompletion "../makesure" "goal" "goalAaa"
checkCompletion "../makesure" "-f ../Makesurefile.txt goal" "goalBbb"
