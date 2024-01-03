function dbgA(name, arr,   i,v) { print "--- " name ": "; for (i in arr) { v = arr[i];gsub(SUBSEP,",",i);printf "%6s : %s\n", i, v }}
function dbgAS(name, arr,   i,v,keys,ki) { print "--- " name ": ";
  for (i in arr) { arrPush(keys,i) }
  quicksort(keys,0,arrLen(keys)-1)
  for (ki=0;ki < arrLen(keys);ki++) { v = arr[i=keys[ki]];gsub(SUBSEP,",",i);printf "%8s : %s\n", i, v }}
function dbgAO(name, arr,   i) { print "--- " name ": "; for (i = 0; i in arr; i++) printf "%2s : %s\n", i, arr[i] }
function dbgLine(   i) { print "--- NR=" NR; for (i=1; i<=NF; i++) printf "%2s : %s\n", i, $i }
function indent(ind) {
  printf "%" ind * 2 "s", ""
}
function printDepsTree(goal,ind,   i) {
  if (!(goal in GoalsByName)) { die("unknown goal: " goal) }
  indent(ind)
  print quote2(goal)
  for (i = 0; i < DependenciesCnt[goal]; i++) {
    printDepsTree(Dependencies[goal,i],ind + 1)
  }
}

function renderArgs(args,   s,k) { s = ""; for (k in args) s = s k "=>" args[k] " "; return s }
