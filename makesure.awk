BEGIN {
  Shell = "bash" # default shell
  SupportedShells["bash"]
  SupportedShells["sh"]
  SupportedOptions["tracing"]
  SupportedOptions["silent"]
  SupportedOptions["timing"]
  delete Lines# line no. -> line
  delete Args # parsed CLI args
  delete ArgGoals # invoked goals
  delete Options
  delete GoalNames     # list
  delete GoalsByName   # g -> private
  delete GoalParamsCnt # g -> params cnt
  delete GoalParams    # g,paramI -> param name
  delete CodePre       # g -> pre-body (should also go before lib)
  delete Code          # g -> body
  delete Vars            # k  -> "val" // @define
  delete DefineOverrides # k  -> ""    // what is passed via --define
  delete Dependencies       # g,depI -> dep goal
  delete DependencyType     # g,depI -> type (D=@depend_on|C=@calls)
  delete DependenciesLineNo # g,depI -> line no.
  delete DependenciesCnt    # g      -> dep cnt
  delete DependencyArgsL    # g,depI -> initial $0, but only when it's @depends_on with @args
  delete Doc       # g -> doc str
  delete ReachedIf # g -> condition line
  GlobCnt = 0      # count of files for glob
  GlobGoalName = ""
  delete GlobFiles # list
  delete LibNames  # list
  delete Lib         # g -> code
  delete UseLibLineNo# g -> line no.
  delete GoalToLib   # g -> lib name
  delete EMPTY
  Mode = "prelude" # prelude|define|goal|goal_glob|lib
  CodeStarted = 0  # first non-blank and non-comment code line went for a goal
  srand()
  prepareArgs()
  ProgAbs = "" # absolute path to makesure executable
  MakesurefileAbs = "" # absolute path to Makesurefile being called
  MyDirScript = "cd " quoteArg(getMyDir(ARGV[1]))
  Error = ""
  makesure()
}

function makesure(   i) {
  while (getline > 0) {
    Lines[NR] = Line0 = $0
    if ($1 ~ /^@/ && "@reached_if" != $1 && !reparseCli()) continue
    if ("@options" == $1) handleOptions()
    else if ("@define" == $1) handleDefine()
    else if ("@shell" == $1) handleShell()
    else if ("@goal" == $1) { if ("@glob" == $2 || "@glob" == $3) handleGoalGlob(); else handleGoal() }
    else if ("@doc" == $1) handleDoc()
    else if ("@depends_on" == $1) handleDependsOn("D")
    else if ("@calls" == $1) handleDependsOn("C")
    else if ("@reached_if" == $1) handleReachedIf()
    else if ("@lib" == $1) handleLib()
    else if ("@use_lib" == $1) handleUseLib()
    else if ($1 ~ /^@/) addError("Unknown directive: " $1)
    else handleCodeLine($0)
    for (i = 1; i < 10; i++) $i = "" # only for macos 10.15 awk version 20070501
  }
  doWork()
  realExit(0)
}

function prepareArgs(   i,arg) {
  for (i = 2; i < ARGC; i++) {
    if (substr(arg = ARGV[i], 1, 1) == "-") {
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
  if ("--timing-skip-total" in Args)
    Options["timing-skip-total"]
}

function splitKV(arg, kv,   n) {
  n = index(arg, "=")
  kv[0] = trim(substr(arg, 1, n - 1))
  kv[1] = trim(substr(arg, n + 1))
}
function handleOptionDefineOverride(arg,   kv) {
  splitKV(arg, kv)
  Vars[kv[0]] = kv[1]
  DefineOverrides[kv[0]]
}

function handleOptions(   i) {
  checkPreludeOnly()

  if (NF < 2)
    addError("Provide at least one option")

  for (i = 2; i <= NF; i++) {
    if (!($i in SupportedOptions))
      addError("Option '" $i "' is not supported")
    Options[$i]
  }
}

function handleDefine() {
  started("define")
  if (NF != 3) {
    addError("Invalid @define syntax, should be @define VAR_NAME 'value'")
    return
  }
  if ($2 !~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
    addError("Wrong variable name: '" $2 "'")
    return
  }
  if (!($2 in DefineOverrides))
    Vars[$2] = $3
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
  else # glob
    for (i = 0; i < GlobCnt; i++)
      registerUseLib(globGoal(i))
}

function registerUseLib(goalName) {
  if (goalName in GoalToLib)
    addError("You can only use one @lib in a @goal")

  GoalToLib[goalName] = $2
  UseLibLineNo[goalName] = NR
}

function handleGoal(   i,goalName) {
  started("goal")
  CodeStarted = 0
  if (registerGoal(parsePriv(), goalName = $2))
    if ("@params" == $3) {
      if (3 == NF) addError("missing parameters")
      for (i = 4; i <= NF; i++)
        GoalParams[goalName, GoalParamsCnt[goalName]++] = validateParamName($i)
    } else if (NF > 2) addError("nothing allowed after goal name")
}

function validateParamName(p) {
  if (p !~ /^[A-Z_][A-Z0-9_]*$/) addError("@param name should match /^[A-Z_][A-Z0-9_]*$/: '" p "'")
  return p
}

function registerGoal(priv, goalName) { # -> 1 if no errors, otherwise 0
  if ("" == goalName || "@params" == goalName)
    addError("Goal must have a name")
  else if (goalName in GoalsByName)
    addError("Goal " quote2(goalName, 1) " is already defined")
  else {
    arrPush(GoalNames, goalName)
    GoalsByName[goalName] = priv
    return 1
  }
}

function globGoal(i) { return (GlobGoalName ? GlobGoalName "@" : "") GlobFiles[i] }
function calcGlob(goalName, pattern,   script, file) {
  GlobCnt = 0
  GlobGoalName = goalName
  delete GlobFiles
  script = MyDirScript ";for f in " pattern ";do test -e \"$f\"&&echo \"$f\"||:;done"
  if ("sh" != Shell)
    script = Shell " -c " quoteArg(script)
  while ((script | getline file) > 0) {
    GlobCnt++
    arrPush(GlobFiles, file)
  }
  closeErr(script)
  quicksort(GlobFiles, 0, arrLen(GlobFiles) - 1)
}

function parsePriv() {
  if ("@private" != $NF) return 0
  $NF = "" # only for macos 10.15 awk version 20070501
  NF--
  return 1 }

function handleGoalGlob(   goalName,globAllGoal,globSingle,priv,i,pattern,nfMax,gi,j,l,globPgParams) {
  started("goal_glob")
  CodeStarted = 0
  priv = parsePriv()
  if ("@glob" == (goalName = $2)) {
    goalName = ""; pattern = $(nfMax = 3)
  } else
    pattern = $(nfMax = 4)
  if (NF > nfMax && "@params" != $(nfMax + 1))
    addError("nothing or @params allowed after glob pattern")
  else if (pattern == "")
    addError("absent glob pattern")
  else {
    if ("@params" == $(nfMax + 1))
      for (i = nfMax + 2; i <= NF; i++)
        arrPush(globPgParams, validateParamName($i))
    calcGlob(goalName, pattern)
    globAllGoal = goalName ? goalName : pattern
    globSingle = GlobCnt == 1 && globAllGoal == globGoal(0)
    for (i = 0; i < GlobCnt; i++) {
      registerGoal(globSingle ? priv : 1, gi = globGoal(i))
      for (j = 0; j in globPgParams; j++)
        GoalParams[gi, GoalParamsCnt[gi]++] = globPgParams[j]
    }
    if (!globSingle) { # glob on single file
      registerGoal(priv, globAllGoal)
      for (j = 0; j in globPgParams; j++)
        GoalParams[globAllGoal, GoalParamsCnt[globAllGoal]++] = globPgParams[j]
      for (i = 0; i < GlobCnt; i++) {
        registerDependency(globAllGoal, globGoal(i), "D")
        if (arrLen(globPgParams)) {
          l = "@depends_on x @params"
          for (j = 0; j in globPgParams; j++)
            l = l " " globPgParams[j]
          DependencyArgsL[globAllGoal, i] = l
        }
      }
    }
  }
}

function handleDoc(   i) {
  checkGoalOnly()

  if ("goal" == Mode)
    registerDoc(currentGoalName())
  else {
    if (!(GlobCnt == 1 && currentGoalName() == globGoal(0))) # glob on single file
      registerDoc(currentGoalName())
    for (i = 0; i < GlobCnt; i++)
      registerDoc(globGoal(i))
  }
}

function registerDoc(goalName) {
  if (goalName in Doc)
    addError("Multiple @doc not allowed for a goal")
  $1 = ""
  Doc[goalName] = trim($0)
}

function handleDependsOn(depType,   i) {
  checkGoalOnly()

  if (NF < 2)
    addError("Provide at least one dependency")

  if ("goal" == Mode)
    registerDependsOn(currentGoalName(), depType)
  else
    for (i = 0; i < GlobCnt; i++)
      registerDependsOn(globGoal(i), depType)
}

function registerDependsOn(goalName,depType,   i,dep) {
  for (i = 2; i <= NF; i++) {
    if ("@args" == (dep = $i)) {
      if (i != 3)
        addError("@args only allowed at position 3")
      DependencyArgsL[goalName, DependenciesCnt[goalName] - 1] = Line0
      break
    } else
      registerDependency(goalName, dep, depType)
  }
}

function registerDependency(goalName, depGoalName, depType,   x) {
  Dependencies[x = goalName SUBSEP DependenciesCnt[goalName]++] = depGoalName
  DependencyType[x] = depType
  DependenciesLineNo[x] = NR
}

# replaces all C-dependencies (@calls) by the code line to invoke makesure
function prepareCalls(   g,cnt,i,x,toDel,codeCalls) {
  for (g in DependenciesCnt) {
    cnt = DependenciesCnt[g]
    codeCalls = ""
    for (i = 0; i < cnt; i++) {
      if ("C" == DependencyType[x = g SUBSEP i]) {
        toDel[x]
        codeCalls = addL(codeCalls, renderCalls(Dependencies[x]))
      }
    }
    Code[g] = addL(codeCalls, Code[g])
  }
  deleteCallDeps(toDel)
}

# not only we need to delete the index, but also to re-number
function deleteCallDeps(toDell,   g,cnt,newCnt,i,x,newX) {
  for (g in DependenciesCnt) {
    cnt = DependenciesCnt[g]
    newCnt = 0
    for (i = 0; i < cnt; i++) {
      if ((x = g SUBSEP i) in toDell) {
        delete Dependencies[x]
        delete DependenciesLineNo[x]
        delete DependencyType[x]
        delete DependencyArgsL[x]
      } else {
        Dependencies[newX = g SUBSEP newCnt++] = Dependencies[x]
        DependenciesLineNo[newX] = DependenciesLineNo[x]
        DependencyType[newX] = DependencyType[x]
        DependencyArgsL[newX] = DependencyArgsL[x]
      }
    }
    DependenciesCnt[g] = newCnt
  }
}

# renders the makesure invocation line of code
function renderCalls(calledGoal,   k,defines) {
  for (k in Vars)
    defines = defines " --define " k "=" quoteArg(Vars[k])
  return quoteArg(ProgAbs)\
      ("silent" in Options ? " --silent" : "")\
      ("timing" in Options ? " --timing --timing-skip-total" : "")\
      ("tracing" in Options ? " --tracing" : "")\
      " --file " quoteArg(MakesurefileAbs) " " quoteArg(calledGoal) defines
}

function handleReachedIf(   i) {
  checkGoalOnly()

  if ("goal" == Mode)
    registerReachedIf(currentGoalName())
  else
    for (i = 0; i < GlobCnt; i++)
      registerReachedIf(globGoal(i), makeGlobVarsCode(i))
}

function makeGlobVarsCode(i) {
  return "ITEM=" quoteArg(GlobFiles[i]) ";INDEX=" i ";TOTAL=" GlobCnt ";"
}

function registerReachedIf(goalName, preScript) {
  if (goalName in ReachedIf)
    addError("Multiple @reached_if not allowed for a goal")

  trimDirective()
  ReachedIf[goalName] = preScript trim($0)
}
# remove the @directive at the start of the line
function trimDirective() {
  sub(/^[ \t]*@[a-z_]+/, "")
}

# cheks for unknown dependencies / libs
function checkBeforeRun(   i,j,dep,depCnt,goalName) {
  for (i = 0; i in GoalNames; i++) {
    depCnt = DependenciesCnt[goalName = GoalNames[i]]
    for (j = 0; j < depCnt; j++)
      if (!((dep = Dependencies[goalName, j]) in GoalsByName))
        addError("Goal " quote2(goalName, 1) " has unknown dependency '" dep "'", DependenciesLineNo[goalName, j])
    if (goalName in GoalToLib && !(GoalToLib[goalName] in Lib))
      addError("Goal " quote2(goalName, 1) " uses unknown lib '" GoalToLib[goalName] "'", UseLibLineNo[goalName])
  }
}

function getPreludeCode(   a,k) {
  addLine(a, MyDirScript)
  for (k in Vars)
    addLine(a, k "=" quoteArg(Vars[k]) ";export " k)
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

  # First do topological sort disregarding @reached_if to catch loops.
  # We need to do it before instantiate, because instantiation is recursive and will hang in presence of loop.
  if (arrLen(GoalNames)) topologicalSort(0, GoalNames)

  instantiateGoals()

  prepareCalls()

  if (Error)
    die(Error)

  list = "-l" in Args || "--list" in Args
  if (list || "-la" in Args || "--list-all" in Args) {
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

    topologicalSort(1, ArgGoals, resolvedGoals, reachedGoals) # now do topological sort including @reached_if to resolve goals to run

    preludeCode = getPreludeCode()

    for (i = 0; i in GoalNames; i++) {
      body = trim(Code[goalName = GoalNames[i]])
      emptyGoals[goalName] = "" == body
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
        printf " %s", quote2(ArgGoals[i], 1)
      print ":"
      for (i = 0; i in resolvedGoals; i++)
        if (!reachedGoals[goalName = resolvedGoals[i]] && !emptyGoals[goalName])
          print "  " quote2(goalName)
    } else {
      for (i = 0; i in resolvedGoals; i++) {
        goalName = resolvedGoals[i]
        goalTimed = timingOn() && !reachedGoals[goalName] && !emptyGoals[goalName]
        if (goalTimed)
          t1 = t2 ? t2 : currentTimeMillis()

        if (!("silent" in Options))
          print "  goal " quote2(goalName, 1) " " (reachedGoals[goalName] ? "[already satisfied]." : emptyGoals[goalName] ? "[empty]." : "...")

        exitCode = (reachedGoals[goalName] || emptyGoals[goalName]) ? 0 : shellExec(goalBodies[goalName], goalName)
        if (exitCode != 0)
          print "  goal " quote2(goalName, 1) " failed"
        if (goalTimed) {
          t2 = currentTimeMillis()
          print "  goal " quote2(goalName, 1) " took " renderDuration(t2 - t1)
        }
        if (exitCode != 0)
          break
      }
      if (timingOn() && !("timing-skip-total" in Options))
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
    for (j = 0; j < depCnt; j++)
      topologicalSortAddConnection(goalName, Dependencies[goalName, j])
  }

  if (arrLen(requestedGoals) == 0)
    arrPush(requestedGoals, "default")

  for (i = 0; i in requestedGoals; i++) {
    if (!((goalName = requestedGoals[i]) in GoalsByName))
      die("Goal not found: " goalName)
    topologicalSortPerform(includeReachedIf, reachedGoals, goalName, result, loop)
  }

  if (loop[0] == 1)
    die("There is a loop in goal dependencies via " loop[1] " -> " loop[2])
}

function isCodeAllowed() { return "goal" == Mode || "goal_glob" == Mode || "lib" == Mode }
function isPrelude() { return "prelude" == Mode }
function checkPreludeOnly() { if (!isPrelude()) addError("Only use " $1 " in prelude") }
function checkGoalOnly() { if ("goal" != Mode && "goal_glob" != Mode || CodeStarted) addError("Only use " $1 " in @goal") }
function currentGoalName() { return arrLast(GoalNames) }
function currentLibName() { return arrLast(LibNames) }

function realExit(code) {
  # place here any cleanup if needed
  exit code
}
function addError(err, n) {
  if ((err, n ? n : (n = NR)) in AddedErrors)
    return
  AddedErrors[err, n] # dedup
  Error = addL(Error, err ":\n" ARGV[1] ":" n ": " Lines[n])
}
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

function getMyDir(makesurefilePath,   script,myDir,p,m,baseName) {
  script = "echo \"$(basename "(m = quoteArg(makesurefilePath))")\";echo \"$(cd \"$(dirname "(p = quoteArg(Prog))")\" && pwd)/$(basename "p")\";cd \"$(dirname " m ")\";pwd"
  script | getline baseName
  script | getline ProgAbs
  script | getline myDir
  closeErr(script)
  MakesurefileAbs = myDir "/" baseName
  return myDir
}

function handleCodeLine(line) {
  if (!isCodeAllowed() && line !~ /^[ \t]*#/ && trim(line) != "") {
    if (!ShellInPreludeErrorShown++)
      addError("Shell code is not allowed outside goals/libs")
  } else {
    addCodeLine(line)
    CodeStarted = CodeStarted || (line = trim(line)) != "" && line !~ /^#/
  }
}

function addCodeLine(line,   goalName, name, i) {
  if ("lib" == Mode) {
    name = currentLibName()
    #print "Append line for '" name "': " line
    Lib[name] = addL(Lib[name], line)
  } else if ("goal_glob" == Mode) {
    for (i = 0; i < GlobCnt; i++) {
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
  delete Visited
  delete Slist
  delete Scnt
}
function topologicalSortAddConnection(from, to) {
  # Slist - list of successors by node
  # Scnt - count of successors by node
  Slist[from, ++Scnt[from]] = to # add 'to' to successors of 'from'
}

function topologicalSortPerform(includeReachedIf,reachedGoals, node, result, loop,   i, s) {
  if (Visited[node] == 2)
    return

  if (includeReachedIf && node in ReachedIf && checkConditionReached(node, ReachedIf[node])) {
    Visited[node] = 2
    arrPush(result, node)
    reachedGoals[node] = 1
    return
  }

  Visited[node] = 1

  for (i = 1; i <= Scnt[node]; i++) {
    if (Visited[s = Slist[node, i]] == 0)
      topologicalSortPerform(includeReachedIf, reachedGoals, s, result, loop)
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
    # should not be possible to list or invoke (non-instantiated) parameterized goals, so let's remove them
  for (goalName in GoalsByName)
    if (GoalParamsCnt[goalName] > 0) {
      arrDel(GoalNames, goalName)
      delete GoalsByName[goalName]
    }
}
#
# args: { F => "file1" }
#
function instantiate(goal,args,newArgs,   i,j,depArg,depArgType,dep,goalNameInstantiated,argsCnt,gi,gii,argsCode,reparsed) { # -> goalNameInstantiated
  if (goal in Instantiated) return goal
  #  indent(IDepth++); print "instantiating " goal " { " renderArgs(args) "} ..."

  Instantiated[goalNameInstantiated = instantiateGoalName(goal, args)]

  if (goalNameInstantiated != goal) {
    if (!(goalNameInstantiated in GoalsByName))
      arrPush(GoalNames, goalNameInstantiated)
    copyKey(goal, goalNameInstantiated, GoalsByName)
    copyKey(goal, goalNameInstantiated, DependenciesCnt)
    copyKey(goal, goalNameInstantiated, CodePre)
    copyKey(goal, goalNameInstantiated, Code)
    copyKey(goal, goalNameInstantiated, Doc)
    copyKey(goal, goalNameInstantiated, ReachedIf)
    copyKey(goal, goalNameInstantiated, GoalToLib)

    for (i in args)
      argsCode = addL(argsCode, i "=" quoteArg(args[i]) ";export " i)

    CodePre[goalNameInstantiated] = addL(CodePre[goalNameInstantiated], argsCode)
    if (goalNameInstantiated in ReachedIf)
      ReachedIf[goalNameInstantiated] = argsCode "\n" ReachedIf[goalNameInstantiated]
  }

  for (i = 0; i < DependenciesCnt[goal]; i++) {
    dep = Dependencies[gi = goal SUBSEP i]

    argsCnt = 0
    if (gi in DependencyArgsL) {
      delete reparsed
      # The idea behind deferring this reparsing to instantiation is to be able to reference both @define vars and PG
      # params in PG arg string interpolation.
      # Already should not fails syntax (checked earlier) - we don't check result code.
      parseCli_2(DependencyArgsL[gi], args, Vars, reparsed)

      argsCnt = reparsed[-7] - 3 # -7 holds len. Subtracting 3, because args start after `@depends_on pg @args`
    }

    # we do not report wrong args count for unknown deps
    if (dep in GoalsByName && argsCnt != GoalParamsCnt[dep])
      addError("wrong args count for '" dep "'", DependenciesLineNo[gi])

    #    indent(IDepth); print ">dep=" dep ", argsCnt[" gi "]=" argsCnt

    for (j = 0; j < argsCnt; j++) {
      depArg = reparsed[j + 3]
      depArgType = "u" == reparsed[j + 3, "quote"] ? "var" : "str"

      #      indent(IDepth); print ">>@ " depArg " " depArgType

      newArgs[GoalParams[dep, j]] = \
        depArgType == "str" ? \
          depArg : \
          depArgType == "var" ? \
            (depArg in args ? args[depArg] : \
             depArg in Vars ? Vars[depArg] : addError("wrong arg '" depArg "'", DependenciesLineNo[gi])) : \
            die("wrong depArgType: " depArgType)
    }

    gii = goalNameInstantiated SUBSEP i
    Dependencies[gii] = instantiate(dep, newArgs)
    DependenciesLineNo[gii] = DependenciesLineNo[gi]
  }

  #  IDepth--
  return goalNameInstantiated
}
function instantiateGoalName(goal, args,   res,cnt,i) {
  if ((cnt = GoalParamsCnt[goal]) == 0) return goal
  res = goal
  for (i = 0; i < cnt; i++)
    res = res "@" args[GoalParams[goal, i]]
  #  print "@@ " res
  return res
}

function currentTimeMillis(   res) {
  if (Gawk)
    return int(gettimeofday() * 1000)
  res = executeGetLine("date +%s%3N")
  sub(/%?3N/, "000", res) # if date doesn't support %N (macos?) just use second-precision
  return +res
}
function incVersion(ver,   arr) {
  split(ver, arr, ".")
  arr[3]++
  return arr[1]"."arr[2]"."arr[3]
}
function selfUpdate(   tmp, err, newVer,line,good,i,found) {
  # Idea: We know current version v0.9.X. We will try next version v0.9.(X+1), v0.9.(X+2), etc. till it's not 404
  good = (tmp = executeGetLine("mktemp /tmp/makesure_new.XXXXXXXXXX"))"_good"
  newVer = Version
  for (;;) {
    if (i++ == 10) { # try max 10 versions up to prevent a possibility of infinite loop
      err = "infinite loop"
      break
    }
    # probe next version
    newVer = incVersion(newVer)
    if (err = dl("https://raw.githubusercontent.com/xonixx/makesure/v" newVer "/makesure", tmp))
      break
    close(tmp)
    if ((getline line < tmp) <= 0) {
      err = "can't check the dl result"
      break
    }
    if (line ~ /^404/) {
      if (found) {
        if (!err && !ok("chmod +x " good)) err = "can't chmod +x " good
        if (!err) {
          newVer = executeGetLine(good " -v")
          if (!ok("cp " good " " quoteArg(Prog)))
            err = "can't overwrite " Prog
          else
            print "updated " Version " -> " newVer
        }
      } else print "you have latest version " Version " installed"
      break
    }
    found = 1
    if (!ok("cp " tmp " " good)) {
      err = "can't cp"
      break
    }
  }
  rm(tmp)
  if (found) rm(good)
  if (err) die(err "\nPlease use manual update: https://makesure.dev/Installation.html")
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
function closeErr(script) { if (close(script) != 0) die("Error executing: " script) }
function dl(url, dest,    verbose,exCode) {
  verbose = "VERBOSE" in ENVIRON
  if (commandExists("wget")) {
    if ((exCode = system("wget " (verbose ? "" : "-q") " " quoteArg(url) " -O" quoteArg(dest) " --content-on-error")) != 0 && exCode != 8) # 404 gives 8, but it's OK for us since we need the content
      return "error with wget: " exCode
  } else if (commandExists("curl")) {
    if (!ok("curl " (verbose ? "" : "-s") " " quoteArg(url) " -o " quoteArg(dest)))
      return "error with curl"
  } else return "wget/curl not found"
}
# s1 > s2 -> 1
# s1== s2 -> 0
# s1 < s2 -> -1
function natOrder(s1,s2, i1,i2,   c1, c2, n1,n2) {
  if (_digit(c1 = substr(s1, i1, 1)) && _digit(c2 = substr(s2, i2, 1))) {
    n1 = +c1; while (_digit(c1 = substr(s1, ++i1, 1))) { n1 = n1 * 10 + c1 }
    n2 = +c2; while (_digit(c2 = substr(s2, ++i2, 1))) { n2 = n2 * 10 + c2 }

    return n1 == n2 ? natOrder(s1, s2, i1, i2) : _cmp(n1, n2)
  }

  # consume till equal substrings
  while ((c1 = substr(s1, i1, 1)) == (c2 = substr(s2, i2, 1)) && c1 != "" && !_digit(c1)) {
    i1++; i2++
  }

  return _digit(c1) && _digit(c2) ? natOrder(s1, s2, i1, i2) : _cmp(c1, c2)
}
function _cmp(v1, v2) { return v1 > v2 ? 1 : v1 < v2 ? -1 : 0 }
function _digit(c) { return c >= "0" && c <= "9" }
function quicksort(data, left, right,   i, last) {
  if (left >= right)
    return
  swap(data, left, int((left + right) / 2))
  last = left
  for (i = left + 1; i <= right; i++)
    if (natOrder(data[i], data[left], 1, 1) < 0)
      swap(data, ++last, i)
  swap(data, left, last)
  quicksort(data, left, last - 1)
  quicksort(data, last + 1, right)
}
function swap(data, i, j,   temp) {
  temp = data[i]
  data[i] = data[j]
  data[j] = temp
}
#
# parses: arg 'arg with spaces' $'arg with \' single quote' "arg ${WITH} $VARS"
#
## res[-7] = res len
## res - 0-based
## returns error if any
function parseCli_2(line, vars, vars2, res,   pos,c,c1,isDoll,q,var,inDef,defVal,val,w,i) {
  for (pos = 1;;) {
    while ((c = substr(line, pos, 1)) == " " || c == "\t") pos++ # consume spaces
    if (c == "#" || c == "")
      return
    else {
      if ((isDoll = substr(line, pos, 2) == "$'") || c == "'" || c == "\"") { # start of string
        if (isDoll)
          pos++
        q = isDoll ? "'" : c # quote
        # consume quoted string
        w = ""
        while ((c = substr(line, ++pos, 1)) != q) { # closing ' or "
          if (c == "")
            return "unterminated argument"
          else if (c == "\\" && ((c1 = substr(line, pos + 1, 1)) == "'" && isDoll || c1 == c || q == "\"" && (c1 == q || c1 == "$"))) { # escaped ' or \ or "
            c = c1; pos++
          } else if (c == "$" && q == "\"") {
            var = ""
            inDef = 0
            defVal = ""
            if ((c1 = substr(line, pos + 1, 1)) == "{") {
              for (pos++; (c = substr(line, ++pos, 1)) != "}";) { # till closing '}'
                if (c == "")
                  return "unterminated argument"
                if (!inDef && ":" == c && "-" == substr(line, pos + 1, 1)) {
                  inDef = 1
                  c = substr(line, pos += 2, 1)
                }
                if (inDef) {
                  if ("}" == c)
                    break
                  if ("\\" == c && ((c1 = substr(line, pos + 1, 1)) == "$" || c1 == "\\" || c1 == "}" || c1 == "\"")) {
                    c = c1; pos++
                  }
                  defVal = defVal c
                } else
                  var = var c
              }
            } else
              for (; (c = substr(line, pos + 1, 1)) ~ /[_A-Za-z0-9]/; pos++)
                var = var c
            #            print "var="var
            if (var !~ /^[_A-Za-z][_A-Za-z0-9]*$/)
              return "wrong var: '" var "'"
            w = (w) ((val = var in vars ? vars[var] : var in vars2 ? vars2[var] : ENVIRON[var]) != "" ? val : defVal)
            continue
          }
          w = w c
        }
        res[i = +res[-7]++, "quote"] = isDoll ? "$" : q
        res[i] = w
        if ((c = substr(line, ++pos, 1)) != "" && c != " " && c != "\t")
          return "joined arguments"
      } else {
        # consume unquoted argument
        w = c
        while ((c = substr(line, ++pos, 1)) != "" && c != " " && c != "\t") { # whitespace denotes the end of arg
          w = w c
        }
        if (w !~ /^[-_A-Za-z0-9@.]+$/)
          return "wrong unquoted: '" w "'"
        res[i = +res[-7]++, "quote"] = "u"
        res[i] = w
      }
    }
  }
}
function reparseCli(   res,i,err) {
  err = parseCli_2($0, Vars, EMPTY, res)
  if (err) {
    addError("Syntax error: " err)
    return 0
  }
  $0 = "" # only for macos 10.15 awk version 20070501
  for (i = NF = 0; i in res; i++)
    $(++NF) = res[i]
  # validation according to https://github.com/xonixx/makesure/issues/141
  for (i = 2; i <= NF; i++)
    if ("\"" == res[i - 1, "quote"] && !("@define" == $1 && 3 == i ||
    "@depends_on" == $1 && "@args" == $3 && i > 3 ||
    "@goal" == $1 && "@glob" == $(i - 1))) {
      addError("Wrong quoting: " $i)
      return 0
    }
  return 1
}
# bash-friendly (non-POSIX-compatible) quoting
function quote2(s,force) {
  if (index(s, "'")) {
    gsub(/\\/, "\\\\", s)
    gsub(/'/, "\\'", s)
    return "$'" s "'"
  } else
    return force || s ~ /[^a-zA-Z0-9.,@_\/=+-]/ ? "'" s "'" : s
}
function addLine(target, line) { target[0] = addL(target[0], line) }
function addL(s, l) { return s ? s "\n" l : l }
function arrPush(arr, elt) { arr[arr[-7]++] = elt }
function arrLen(arr) { return +arr[-7] }
function arrDel(arr, v,   l,i,e,resArr) {
  l = arrLen(arr)
  for (i = 0; i < l; i++)
    if (v != (e = arr[i]))
      arrPush(resArr, e)
  delete arr
  for (i in resArr)
    arr[i] = resArr[i]
}
function arrLast(arr,   l) { return (l = arrLen(arr)) > 0 ? arr[l - 1] : "" }
function commandExists(cmd) { return ok("command -v " cmd " >/dev/null") }
function ok(cmd) { return system(cmd) == 0 }
function isFile(path) { return ok("test -f " quoteArg(path)) }
function rm(f) { system("rm " quoteArg(f)) }
# POSIX-compatible quoting
function quoteArg(a) { gsub("'", "'\\''", a); return "'" a "'" }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
function copyKey(keySrc,keyDst,arr) { if (keySrc in arr) arr[keyDst] = arr[keySrc] }