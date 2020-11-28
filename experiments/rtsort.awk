# rtsort - reverse topological sort
#   input:  predecessor-successor pairs
#   output: linear order, successors first

    { if (!($1 in pcnt))
          pcnt[$1] = 0           # put $1 in pcnt
      pcnt[$2]++                 # count predecessors of $2
      slist[$1, ++scnt[$1]] = $2 # add $2 to successors of $1
    }

END {
     #for (node in pcnt) {
     #     nodecnt++
     #     if (pcnt[node] == 0) {
     #         print "rtsort " node
     #         rtsort(node)
     #     }
     # }
     # if (pncnt != nodecnt)
     #     print "error: input contains a cycle" pncnt " " nodecnt
     # printf("\n")

     rtsort("a")
    }

function rtsort(node,     i, s) {
    print "marking visited 1 " node
    visited[node] = 1
    for (i = 1; i <= scnt[node]; i++)
        if (visited[s = slist[node, i]] == 0)
            rtsort(s)
        else if (visited[s] == 1)
            printf("error: nodes %s and %s are in a cycle\n",
                s, node)
    visited[node] = 2
    printf(" %s", node)
    pncnt++    # count nodes printed
}