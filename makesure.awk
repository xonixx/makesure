BEGIN {
  Shell = "bash" # default shell
  SupportedShells["bash"]
  SupportedShells["sh"]
  SupportedOptions["tracing"]
  SupportedOptions["silent"]
  SupportedOptions["timing"]
  split("",Lines)# line no. -> line
  split("",Args) # parsed CLI args
  split("",ArgGoals) # invoked goals
  split("",Options)
  split("",GoalNames)   # list
  split("",GoalsByName) # name -> private
  split("",GoalParamsCnt) # name -> params cnt
  split("",GoalParams)    # name,paramI -> param name
  split("",CodePre)     # name -> pre-body (should also go before lib)
  split("",Code)        # name -> body
  split("",DefineOverrides) # k -> ""
  DefinesCode=""
  split("",Dependencies)       # name,i -> dep goal
  split("",DependenciesLineNo) # name,i -> line no.
  split("",DependenciesCnt)    # name   -> dep cnt
  split("",DependencyArgsCnt)  # name,i -> args cnt
  split("",DependencyArgs)     # name,depI,argI -> val
  split("",DependencyArgsType) # name,depI,argI -> str|var
  split("",Doc)       # name -> doc str
  split("",ReachedIf) # name -> condition line
  GlobCnt = 0         # count of files for glob
  GlobGoalName = ""
  split("",GlobFiles) # list
  split("",LibNames) # list
  split("",Lib)      # name -> code
  split("",UseLibLineNo)# name -> line no.
  split("",GoalToLib)# goal name -> lib name
  split("",Quotes)   # NF -> quote of field ("'"|"$"|"")
  Mode = "prelude" # prelude|define|goal|goal_glob|lib
  srand()
  prepareArgs()
  MyDirScript = "MYDIR=" quoteArg(getMyDir(ARGV[1])) ";export MYDIR;cd \"$MYDIR\""
  Error=""
  makesure()
}

function makesure() {
  while (getline > 0) {
    Lines[NR]=$0
    if ($1 ~ /^@/ && "@define" != $1 && "@reached_if" != $1) reparseCli()
    if ("@options" == $1) handleOptions()
    else if ("@define" == $1) handleDefine()
    else if ("@shell" == $1) handleShell()
    else if ("@goal" == $1) { if ("@glob" == $2 || "@glob" == $3) handleGoalGlob(); else handleGoal() }
    else if ("@doc" == $1) handleDoc()
    else if ("@depends_on" == $1) handleDependsOn()
    else if ("@reached_if" == $1) handleReachedIf()
    else if ("@lib" == $1) handleLib()
    else if ("@use_lib" == $1) handleUseLib()
    else if ($1 ~ /^@/) addError("Unknown directive: " $1)
    else handleCodeLine($0)
  }
  doWork()
  realExit(0)
}

function prepareArgs(   i,arg) {
  for (i = 2; i < ARGC; i++) {
    arg = ARGV[i]
    #print i " " arg
    if (substr(arg,1,1) == "-") {
      if (arg == "-f" || arg == "--file") {
        delete ARGV[i]
        ARGV[1] = ARGV[++i]
      } else if (arg == "-D" || arg == "--define") {
        delete ARGV[i]
        handleOptionDefineOverride(ARGV[++i])
      } else
        Args[arg]
    } else
      arrPush(ArgGoals, arg)

    delete ARGV[i] # https://unix.stackexchange.com/a/460375
  }
  if ("-h" in Args || "--help" in Args) {
    print "makesure ver. " Version
    print "Usage: makesure [options...] [-f buildfile] [goals...]"
    print " -f,--file buildfile"
    print "                 set buildfile to use (default Makesurefile)"
    print " -l,--list       list all available non-@private goals"
    print " -la,--list-all  list all available goals"
    print " -d,--resolved   list resolved dependencies to reach given goals"
    print " -D \"var=val\",--define \"var=val\""
    print "                 override @define values"
    print " -s,--silent     silent mode - only output what goals output"
    print " -t,--timing     display execution times for goals and total"
    print " -x,--tracing    enable tracing in bash/sh via `set -x`"
    print " -v,--version    print version and exit"
    print " -h,--help       print help and exit"
    print " -U,--selfupdate update makesure to latest version"
    realExit(0)
  } else if ("-v" in Args || "--version" in Args) {
    print Version
    realExit(0)
  } else if ("-U" in Args || "--selfupdate" in Args) {
    selfUpdate()
    realExit(0)
  }
  if (!isFile(ARGV[1])) {
    if (isFile(ARGV[1] "/Makesurefile"))
      ARGV[1] = ARGV[1] "/Makesurefile"
    else
      die("makesure file not found: " ARGV[1])
  }
  if ("-s" in Args || "--silent" in Args)
    Options["silent"]
  if ("-x" in Args || "--tracing" in Args)
    Options["tracing"]
  if ("-t" in Args || "--timing" in Args)
    Options["timing"]
}

#function dbgA(name, arr,   i) { print "--- " name ": "; for (i in arr) printf "%2s : %s\n", i, arr[i] }
#function dbgAO(name, arr,   i) { print "--- " name ": "; for (i=0;i in arr;i++) printf "%2s : %s\n", i, arr[i] }
#function indent(ind) {
#  printf "%" ind*2 "s", ""
#}
#function printDepsTree(goal,ind,   i) {
#  if (!(goal in GoalsByName)) { die("unknown goal: " goal) }
#  indent(ind)
#  print quote2(goal)
#  for (i=0; i < DependenciesCnt[goal]; i++) {
#    printDepsTree(Dependencies[goal,i],ind+1)
#  }
#}

function splitKV(arg, kv,   n) {
  n = index(arg, "=")
  kv[0] = trim(substr(arg,1,n-1))
  kv[1] = trim(substr(arg,n+1))
}
function handleOptionDefineOverride(arg,   kv) {
  splitKV(arg, kv)
  handleDefineLine(kv[0] "=" quoteArg(kv[1]))
  DefineOverrides[kv[0]]
}

function handleOptions(   i) {
  checkPreludeOnly()

  if (NF<2)
    addError("Provide at least one option")

  for (i=2; i<=NF; i++) {
    if (!($i in SupportedOptions))
      addError("Option '" $i "' is not supported")
    Options[$i]
  }
}

function handleDefine() {
  started("define")
  $1 = ""
  handleDefineLine($0)
}
function handleDefineLine(line,   kv) {
  if (!checkValidDefineSyntax(line))
    return

  splitKV(line, kv)

  if (!(kv[0] in DefineOverrides))
    DefinesCode = addL(DefinesCode, line "\nexport " kv[0])
}
function checkValidDefineSyntax(line) {
  if (line ~ /^[ \t]*[A-Za-z_][A-Za-z0-9_]*=(([A-Za-z0-9_]|(\\.))+|('[^']*')|("((\\\\)|(\\")|[^"])*")|(\$'((\\\\)|(\\')|[^'])*'))*[ \t]*(#.*)?$/)
    return 1
  addError("Invalid define declaration")
  return 0
}

function handleShell() {
  checkPreludeOnly()
  if (!((Shell = $2) in SupportedShells))
    addError("Shell '" Shell "' is not supported")
}

function timingOn() {
  return "timing" in Options && !("silent" in Options)
}

function started(mode) {
  Mode = mode
}

function handleLib(   libName) {
  started("lib")
  if ((libName = $2) in Lib) {
    addError("Lib '" libName "' is already defined")
  }
  arrPush(LibNames, libName)
  Lib[libName]
}

function handleUseLib(   i) {
  checkGoalOnly()

  if ("goal" == Mode)
    registerUseLib(currentGoalName())
  else
    for (i=0; i < GlobCnt; i++)
      registerUseLib(globGoal(i))
}

function registerUseLib(goalName) {
  if (goalName in GoalToLib)
    addError("You can only use one @lib in a @goal")

  GoalToLib[goalName] = $2
  UseLibLineNo[goalName] = NR
}

function handleGoal() {
  started("goal")
  registerGoal($2, isPriv())
}

function registerGoal(goalName, priv,   i) {
  if (goalName == "")
    addError("Goal must have a name")
  if (goalName in GoalsByName)
    addError("Goal " quote2(goalName,1) " is already defined")
  arrPush(GoalNames, goalName)
  GoalsByName[goalName] = priv
  if ("@params" == $3)
    for (i=4; i <= NF; i++)
      GoalParams[goalName,GoalParamsCnt[goalName]++] = $i # TODO $NF=="@private"?
      # TODO error if @params on other position
}

function globGoal(i) { return (GlobGoalName ? GlobGoalName "@" : "") GlobFiles[i] }
function calcGlob(goalName, pattern,   script, file) {
  GlobCnt = 0
  GlobGoalName = goalName
  split("",GlobFiles)
  script = MyDirScript ";for f in " pattern ";do test -e \"$f\"&&echo \"$f\"||:;done"
  if ("sh" != Shell)
    script = Shell " -c " quoteArg(script)
  while ((script | getline file)>0) {
    GlobCnt++
    arrPush(GlobFiles,file)
  }
  closeErr(script)
  quicksort(GlobFiles,0,arrLen(GlobFiles)-1)
}

function isPriv() { return "@private" == $NF }

function handleGoalGlob(   goalName,globAllGoal,globSingle,priv,i,pattern) {
  started("goal_glob")
  priv = isPriv()
  goalName = $2; pattern = $4
  if ("@glob" == goalName) {
    goalName = ""; pattern = $3
  }
  calcGlob(goalName, pattern)
  globAllGoal = goalName ? goalName : pattern
  globSingle = GlobCnt == 1 && globAllGoal == globGoal(0)
  for (i=0; i < GlobCnt; i++)
    registerGoal(globGoal(i), globSingle ? priv : 1)
  if (!globSingle) { # glob on single file
    registerGoal(globAllGoal, priv)
    for (i=0; i < GlobCnt; i++)
      registerDependency(globAllGoal, globGoal(i))
  }
}

function handleDoc(   i) {
  checkGoalOnly()

  if ("goal" == Mode)
    registerDoc(currentGoalName())
  else {
    if (!(GlobCnt == 1 && currentGoalName() == globGoal(0))) # glob on single file
      registerDoc(currentGoalName())
    for (i=0; i < GlobCnt; i++)
      registerDoc(globGoal(i))
  }
}

function registerDoc(goalName) {
  if (goalName in Doc)
    addError("Multiple " $1 " not allowed for a goal")
  $1 = ""
  Doc[goalName] = trim($0)
}

function handleDependsOn(   i) {
  checkGoalOnly()

  if (NF<2)
    addError("Provide at least one dependency")

  if ("goal" == Mode)
    registerDependsOn(currentGoalName())
  else
    for (i=0; i < GlobCnt; i++)
      registerDependsOn(globGoal(i))
}

function registerDependsOn(goalName,   i,dep,x,y) {
  for (i=2; i<=NF; i++) {
    dep = $i
    if ("@args" == dep) {
      if (i != 3) addError("@args only allowed at position 3") # TODO finalize error msg
      if (i == NF) addError("must be at least one argument") # TODO finalize error msg
      while (++i <= NF) {
        x = goalName SUBSEP (DependenciesCnt[goalName]-1)
        y = x SUBSEP DependencyArgsCnt[x]++
        DependencyArgs[y] = $i
        DependencyArgsType[y] = Quotes[i] ? "str" : "var"
      }
    } else
      registerDependency(goalName, dep)
  }
}

function registerDependency(goalName, depGoalName,   x) {
  Dependencies[x = goalName SUBSEP DependenciesCnt[goalName]++] = depGoalName
  DependenciesLineNo[x] = NR
}

function handleReachedIf(   i) {
  checkGoalOnly()

  if ("goal" == Mode)
    registerReachedIf(currentGoalName())
  else
    for (i=0; i < GlobCnt; i++)
      registerReachedIf(globGoal(i), makeGlobVarsCode(i))
}

function makeGlobVarsCode(i) {
  return "ITEM=" quoteArg(GlobFiles[i]) ";INDEX=" i ";TOTAL=" GlobCnt ";"
}

function registerReachedIf(goalName, preScript) {
  if (goalName in ReachedIf)
    addError("Multiple " $1 " not allowed for a goal")

  $1 = ""
  ReachedIf[goalName] = preScript trim($0)
}

function checkBeforeRun(   i,j,dep,depCnt,goalName,visited) {
  for (i = 0; i in GoalNames; i++) {
    goalName = GoalNames[i]
    if (visited[goalName]++)
      continue
    depCnt = DependenciesCnt[goalName]
    for (j=0; j < depCnt; j++)
      if (!((dep = Dependencies[goalName, j]) in GoalsByName))
        addError("Goal " quote2(goalName,1) " has unknown dependency '" dep "'", DependenciesLineNo[goalName, j])
    if (goalName in GoalToLib && !(GoalToLib[goalName] in Lib))
      addError("Goal " quote2(goalName,1) " uses unknown lib '" GoalToLib[goalName] "'", UseLibLineNo[goalName])
  }
}

function getPreludeCode(   a) {
  addLine(a, MyDirScript)
  addLine(a, DefinesCode)
  return a[0]
}

function doWork(\
  i,goalName,gnLen,gnMaxLen,reachedGoals,emptyGoals,preludeCode,
body,goalBody,goalBodies,resolvedGoals,exitCode, t0,t1,t2, goalTimed, list) {

  started("end") # end last directive

  checkBeforeRun()

#  dbgA("GoalParamsCnt",GoalParamsCnt)
#  dbgA("GoalParams",GoalParams)
#  dbgA("DependencyArgsCnt",DependencyArgsCnt)
#  dbgA("DependencyArgs",DependencyArgs)
#  dbgA("DependencyArgsType",DependencyArgsType)

  if (Error)
    die(Error)

  list="-l" in Args || "--list" in Args
  if (list || "-la" in Args || "--list-all" in Args) {
    instantiateGoals()
    print "Available goals:"
    for (i = 0; i in GoalNames; i++) {
      goalName = GoalNames[i]
      if (list && GoalsByName[goalName]) # private
        continue
      if ((gnLen = length(quote2(goalName))) > gnMaxLen && gnLen <= 30)
        gnMaxLen = gnLen
    }
    for (i = 0; i in GoalNames; i++) {
      goalName = GoalNames[i]
      if (list && GoalsByName[goalName]) # private
        continue
      printf "  "
      if (goalName in Doc)
        printf "%-" gnMaxLen "s : %s\n", quote2(goalName), Doc[goalName]
      else
        print quote2(goalName)
    }
  } else {
    if (timingOn())
      t0 = currentTimeMillis()

    topologicalSort(0,GoalNames) # first do topological sort disregarding @reached_if to catch loops

    instantiateGoals()

#    printDepsTree("a")

    topologicalSort(1,ArgGoals,resolvedGoals,reachedGoals) # now do topological sort including @reached_if to resolve goals to run

#    printDepsTree("a")

    preludeCode = getPreludeCode()

    for (i = 0; i in GoalNames; i++) {
      emptyGoals[goalName] = "" == (body = trim(Code[goalName = GoalNames[i]]))

      goalBody[0] = ""
      addLine(goalBody, preludeCode)
      addLine(goalBody, CodePre[goalName])
      if (goalName in GoalToLib)
        addLine(goalBody, Lib[GoalToLib[goalName]])

      addLine(goalBody, body)
      goalBodies[goalName] = goalBody[0]
    }

    if ("-d" in Args || "--resolved" in Args) {
      printf "Resolved goals to reach for"
      for (i = 0; i in ArgGoals; i++)
        printf " %s", quote2(ArgGoals[i],1)
      print ":"
      for (i = 0; i in resolvedGoals; i++)
        if (!reachedGoals[goalName=resolvedGoals[i]] && !emptyGoals[goalName])
          print "  " quote2(goalName)
    } else {
      for (i = 0; i in resolvedGoals; i++) {
        goalName = resolvedGoals[i]
        goalTimed = timingOn() && !reachedGoals[goalName] && !emptyGoals[goalName]
        if (goalTimed)
          t1 = t2 ? t2 : currentTimeMillis()

        if (!("silent" in Options))
          print "  goal " quote2(goalName,1) " " (reachedGoals[goalName] ? "[already satisfied]." : emptyGoals[goalName] ? "[empty]." : "...")

        exitCode = (reachedGoals[goalName] || emptyGoals[goalName]) ? 0 : shellExec(goalBodies[goalName],goalName)
        if (exitCode != 0)
          print "  goal " quote2(goalName,1) " failed"
        if (goalTimed) {
          t2 = currentTimeMillis()
          print "  goal " quote2(goalName,1) " took " renderDuration(t2 - t1)
        }
        if (exitCode != 0)
          break
      }
      if (timingOn())
        print "  total time " renderDuration((t2 ? t2 : currentTimeMillis()) - t0)
      if (exitCode != 0)
        realExit(exitCode)
    }
  }
}

function topologicalSort(includeReachedIf,requestedGoals,result,reachedGoals,   i,j,goalName,loop,depCnt) {
  topologicalSortReset()

  for (i = 0; i in GoalNames; i++) {
    depCnt = DependenciesCnt[goalName = GoalNames[i]]
    for (j=0; j < depCnt; j++)
      topologicalSortAddConnection(goalName, Dependencies[goalName, j])
  }

  if (arrLen(requestedGoals) == 0)
    arrPush(requestedGoals, "default")

  for (i = 0; i in requestedGoals; i++) {
    if (!((goalName = requestedGoals[i]) in GoalsByName))
      die("Goal not found: " goalName)
    topologicalSortPerform(includeReachedIf,reachedGoals, goalName, result, loop)
  }

  if (loop[0] == 1)
    die("There is a loop in goal dependencies via " loop[1] " -> " loop[2])
}

function isCodeAllowed() { return "goal"==Mode || "goal_glob"==Mode || "lib"==Mode }
function isPrelude() { return "prelude"==Mode }
function checkPreludeOnly() { if (!isPrelude()) addError("Only use " $1 " in prelude") }
function checkGoalOnly() { if ("goal" != Mode && "goal_glob" != Mode) addError("Only use " $1 " in @goal") }
function currentGoalName() { return arrLast(GoalNames) }
function currentLibName() { return arrLast(LibNames) }

function realExit(code) {
  # place here any cleanup if needed
  exit code
}
function addError(err, n) { if (!n) n=NR; Error=addL(Error, err ":\n" ARGV[1] ":" n ": " Lines[n]) }
function die(msg,    out) {
  out = "cat 1>&2" # trick to write from awk to stderr
  print msg | out
  close(out)
  realExit(1)
}

function checkConditionReached(goalName, conditionStr,    script) {
  script = getPreludeCode() # need this to initialize variables for check conditions
  if (goalName in GoalToLib)
    script = script "\n" Lib[GoalToLib[goalName]]
  script = script "\n" conditionStr
  #print "script: " script
  return shellExec(script, goalName "@reached_if") == 0
}

function shellExec(script, comment,   res) {
  if ("tracing" in Options) {
    script = ": " quoteArg(comment) "\n" script
    script = Shell " -x -e -c " quoteArg(script)
  } else
    script = Shell " -e -c " quoteArg(script)

    # This is hard to unit-test properly.
    # The issue with Ctrl-C only happens with Gawk 4.1.3.
    # The manual test exists via `expect -f tests/manual_ctrl_c.expect.txt`
  script = "trap 'exit 7' INT;" script

  #print script
  res = system(script)
  #print "res " res
  return res
}

function getMyDir(makesurefilePath) {
  return executeGetLine("cd \"$(dirname " quoteArg(makesurefilePath) ")\";pwd")
}

function handleCodeLine(line) {
  if (!isCodeAllowed() && line !~ /^[ \t]*#/ && trim(line) != "") {
    if (!ShellInPreludeErrorShown++)
      addError("Shell code is not allowed outside goals/libs")
  } else
    addCodeLine(line)
}

function addCodeLine(line,   goalName, name, i) {
  if ("lib" == Mode) {
    name = currentLibName()
    #print "Append line for '" name "': " line
    Lib[name] = addL(Lib[name], line)
  } else if ("goal_glob" == Mode) {
    for (i=0; i < GlobCnt; i++){
      if (!CodePre[goalName = globGoal(i)])
        CodePre[goalName] = makeGlobVarsCode(i)
      addCodeLineToGoal(goalName, line)
    }
  } else
    addCodeLineToGoal(currentGoalName(), line)
}

function addCodeLineToGoal(name, line) {
  #print "Append line for '" name "': " line
  Code[name] = addL(Code[name], line)
}

function topologicalSortReset() {
  split("",Visited)
  split("",Slist)
  split("",Scnt)
}
function topologicalSortAddConnection(from, to) {
  # Slist - list of successors by node
  # Scnt - count of successors by node
  Slist[from, ++Scnt[from]] = to # add 'to' to successors of 'from'
}

function topologicalSortPerform(includeReachedIf,reachedGoals, node, result, loop,   i, s) {
  if (Visited[node] == 2)
    return

  if (includeReachedIf && node in ReachedIf && checkConditionReached(node, ReachedIf[node])){
    Visited[node] = 2
    arrPush(result, node)
    reachedGoals[node] = 1
    return
  }

  Visited[node] = 1

  for (i = 1; i <= Scnt[node]; i++) {
    if (Visited[s = Slist[node, i]] == 0)
      topologicalSortPerform(includeReachedIf,reachedGoals, s, result, loop)
    else if (Visited[s] == 1) {
      loop[0] = 1
      loop[1] = s
      loop[2] = node
    }
  }

  Visited[node] = 2

  arrPush(result, node)
}

function instantiateGoals(   i,l,goalName) {
  l = arrLen(GoalNames)
  for (i = 0; i < l; i++)
    if (GoalParamsCnt[goalName = GoalNames[i]] == 0)
      instantiate(goalName)
}
#function renderArgs(args,   s,k) { s = ""; for (k in args) s = s k "=>" args[k] " "; return s }
function copyKey(keySrc,keyDst,arr) { if (keySrc in arr) arr[keyDst] = arr[keySrc] }
#
# args: { F => "file1" }
#
function instantiate(goal,args,newArgs,   i,j,depArg,depArgType,dep,goalNameInstantiated,argsCnt) { # -> goalNameInstantiated
#  print ">instantiating " goal " { " renderArgs(args) "} ..."

  if (!(goal in GoalsByName)) { die("unknown goal: " goal) }

  goalNameInstantiated = instantiateGoalName(goal, args)

  if (goalNameInstantiated != goal) {
    arrPush(GoalNames, goalNameInstantiated)
    copyKey(goal,goalNameInstantiated,GoalsByName)
    copyKey(goal,goalNameInstantiated,DependenciesCnt)
    copyKey(goal,goalNameInstantiated,CodePre) # TODO attach dependency var values
    copyKey(goal,goalNameInstantiated,Code)
    copyKey(goal,goalNameInstantiated,Doc)
    copyKey(goal,goalNameInstantiated,ReachedIf)
    copyKey(goal,goalNameInstantiated,GoalToLib)
  }

  for (i=0; i < DependenciesCnt[goal]; i++) {
    # TODO goal,i to var
    dep = Dependencies[goal,i]

    if ((argsCnt = DependencyArgsCnt[goal,i]) != GoalParamsCnt[dep]) { addError("wrong args count", DependenciesLineNo[goal,i]) }

    #    print "argsCnt " argsCnt

    for (j=0; j < argsCnt; j++) {
      depArg     = DependencyArgs    [goal,i,j]
      depArgType = DependencyArgsType[goal,i,j]

      #      print "@ " depArg " " depArgType

      newArgs[GoalParams[dep,j]] = \
        depArgType == "str" ? \
          depArg : \
          depArgType == "var" ? \
            (depArg in args ? args[depArg] : addError("wrong arg " depArg, DependenciesLineNo[goal,i])) : \
            die("wrong depArgType: " depArgType)
    }

    Dependencies[goalNameInstantiated,i] = instantiate(dep,newArgs)
    DependenciesLineNo[goalNameInstantiated,i] = DependenciesLineNo[goal,i]
  }

  return goalNameInstantiated
}
function instantiateGoalName(goal, args,   res,cnt,i){
  if ((cnt = GoalParamsCnt[goal]) == 0) { return goal }
  res = goal
  for (i=0; i < cnt; i++) {
    res = res "@" args[GoalParams[goal,i]]
  }
  #  print "@@ " res
  return res
}

function currentTimeMillis(   res) {
  if (Gawk)
    return int(gettimeofday()*1000)
  res = executeGetLine("date +%s%3N")
  sub(/%?3N/, "000", res) # if date doesn't support %N (macos?) just use second-precision
  return +res
}

function selfUpdate(   url, tmp, err, newVer) {
  url = "https://raw.githubusercontent.com/xonixx/makesure/main/makesure?token=" rand()
  tmp = executeGetLine("mktemp /tmp/makesure_new.XXXXXXXXXX")
  err = dl(url, tmp)
  if (!err && !ok("chmod +x " tmp)) err = "can't chmod +x " tmp
  if (!err) {
    newVer = executeGetLine(tmp " -v")
    if (Version != newVer) {
      if (!ok("cp " tmp " " quoteArg(Prog)))
        err = "can't overwrite " Prog
      else print "updated " Version " -> " newVer
    } else print "you have latest version " Version " installed"
  }
  rm(tmp)
  if (err) die(err)
}

function renderDuration(deltaMillis,\
  deltaSec,deltaMin,deltaHr,deltaDay,dayS,hrS,minS,secS,secSI,res) {

  deltaSec = deltaMillis / 1000
  deltaMin = 0
  deltaHr = 0
  deltaDay = 0

  if (deltaSec >= 60) {
    deltaMin = int(deltaSec / 60)
    deltaSec = deltaSec - deltaMin * 60
  }

  if (deltaMin >= 60) {
    deltaHr = int(deltaMin / 60)
    deltaMin = deltaMin - deltaHr * 60
  }

  if (deltaHr >= 24) {
    deltaDay = int(deltaHr / 24)
    deltaHr = deltaHr - deltaDay * 24
  }

  dayS = deltaDay > 0 ? deltaDay " d" : ""
  hrS = deltaHr > 0 ? deltaHr " h" : ""
  minS = deltaMin > 0 ? deltaMin " m" : ""
  secS = deltaSec > 0 ? deltaSec " s" : ""
  secSI = deltaSec > 0 ? int(deltaSec) " s" : ""

  if (dayS != "")
    res = dayS " " (hrS == "" ? "0 h" : hrS)
  else if (deltaHr > 0)
    res = hrS " " (minS == "" ? "0 m" : minS)
  else if (deltaMin > 0)
    res = minS " " (secSI == "" ? "0 s" : secSI)
  else
    res = deltaSec > 0 ? secS : "0 s"

  return res
}
function executeGetLine(script,   res) {
  script | getline res
  closeErr(script)
  return res
}
function closeErr(script) { if (close(script)!=0) die("Error executing: " script) }
function dl(url, dest,    verbose) {
  verbose = "VERBOSE" in ENVIRON
  if (commandExists("wget")) {
    if (!ok("wget " (verbose ? "" : "-q") " " quoteArg(url) " -O" quoteArg(dest)))
      return "error with wget"
  } else if (commandExists("curl")) {
    if (!ok("curl " (verbose ? "" : "-s") " " quoteArg(url) " -o " quoteArg(dest)))
      return "error with curl"
  } else return "wget/curl not found"
}
# s1 > s2 -> 1
# s1== s2 -> 0
# s1 < s2 -> -1
function natOrder(s1,s2, i1,i2,   c1, c2, n1,n2) {
  if (_digit(c1 = substr(s1,i1,1)) && _digit(c2 = substr(s2,i2,1))) {
    n1 = +c1; while(_digit(c1 = substr(s1,++i1,1))) { n1 = n1 * 10 + c1 }
    n2 = +c2; while(_digit(c2 = substr(s2,++i2,1))) { n2 = n2 * 10 + c2 }

    return n1 == n2 ? natOrder(s1, s2, i1, i2) : _cmp(n1, n2)
  }

  # consume till equal substrings
  while ((c1 = substr(s1,i1,1)) == (c2 = substr(s2,i2,1)) && c1 != "" && !_digit(c1)) {
    i1++; i2++
  }

  return _digit(c1) && _digit(c2) ? natOrder(s1, s2, i1, i2) : _cmp(c1, c2)
}
function _cmp(v1, v2) { return v1 > v2 ? 1 : v1 < v2 ? -1 : 0 }
function _digit(c) { return c >= "0" && c <= "9" }
function quicksort(data, left, right,   i, last) {
  if (left >= right)
    return
  quicksortSwap(data, left, int((left + right) / 2))
  last = left
  for (i = left + 1; i <= right; i++)
    if (natOrder(data[i], data[left],1,1) < 0)
      quicksortSwap(data, ++last, i)
  quicksortSwap(data, left, last)
  quicksort(data, left, last - 1)
  quicksort(data, last + 1, right)
}
function quicksortSwap(data, i, j,   temp) {
  temp = data[i]
  data[i] = data[j]
  data[j] = temp
}
function parseCli(line, res,   pos,c,last,is_doll,c1) {
  for(pos=1;;) {
    while((c = substr(line,pos,1))==" " || c == "\t") pos++ # consume spaces
    if ((c = substr(line,pos,1))=="#" || c=="")
      return
    else {
      if ((is_doll = c == "$") && substr(line,pos+1,1)=="'" || c == "'") { # start of string
        if(is_doll)
          pos++
          # consume quoted string
        res[last = res[-7]++] = ""
        res[last,"quote"] = is_doll ? "$" : "'"
        while((c = substr(line,++pos,1)) != "'") { # closing '
          if (c=="")
            return "unterminated argument"
          else if (is_doll && c=="\\" && ((c1=substr(line,pos+1,1))=="'" || c1==c)) { # escaped ' or \
            c = c1; pos++
          }
          res[last] = res[last] c
        }
        if((c = substr(line,++pos,1)) != "" && c != " " && c != "\t")
          return "joined arguments"
      } else {
        # consume unquoted argument
        res[last = res[-7]++] = c
        while((c = substr(line,++pos,1)) != "" && c != " " && c != "\t") { # whitespace denotes the end of arg
          if(c=="'")
            return "joined arguments"
          res[last] = res[last] c
        }
      }
    }
  }
}
function reparseCli(   res,i,err) {
  err = parseCli($0, res)
  if (err) {
    addError("Syntax error: " err)
    die(Error)
  } else
    for (i=NF=0; i in res; i++) {
      $(++NF)=res[i]
      Quotes[NF]=res[i,"quote"]
    }
}
function quote2(s,force) {
  if (index(s,"'")) {
    gsub(/\\/,"\\\\",s)
    gsub(/'/,"\\'",s)
    return "$'" s "'"
  } else
    return force || s ~ /[^a-zA-Z0-9.,@_\/=+-]/ ? "'" s "'" : s
}
function addLine(target, line) { target[0] = addL(target[0], line) }
function addL(s, l) { return s ? s "\n" l : l }
function arrPush(arr, elt) { arr[arr[-7]++] = elt }
function arrLen(arr) { return +arr[-7] }
function arrLast(arr,   l) { return (l = arrLen(arr))>0 ? arr[l-1] : "" }
function commandExists(cmd) { return ok("command -v " cmd " >/dev/null") }
function ok(cmd) { return system(cmd) == 0 }
function isFile(path) { return ok("test -f " quoteArg(path)) }
function rm(f) { system("rm " quoteArg(f)) }
function quoteArg(a) { gsub("'", "'\\''", a); return "'" a "'" }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }