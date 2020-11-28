
BEGIN {
    print 111
    print "a=AAA" | "bash -e"
    print 222
    print "echo $a" | "bash -e"
    close("bash -e")
}

