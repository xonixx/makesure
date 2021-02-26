BEGIN {
    Shell = "bash" # default shell
    SupportedShells["bash"]
    SupportedShells["sh"]
    SupportedOptions["tracing"]
    SupportedOptions["silent"]
    SupportedOptions["timing"]
    prepareArgs()
}

"@options"    == $1 { handleOptions();     next }
"@define"     == $1 { handleDefine();      next }
"@shell"      == $1 { handleShell();       next }
"@goal"       == $1 { handleGoal();        next }
"@doc"        == $1 { handleDoc();         next }
"@depends_on" == $1 { handleDependsOn();   next }
"@reached_if" == $1 { handleReachedIf();   next }
                    { handleCodeLine($0);  next }

END { if (!Died) doWork() }

function prepareArgs(    i,arg) {
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
      print " -l,--list       list all available goals"
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
        dieMsg("makesure file not found: " ARGV[1])
    }
    if ("-s" in Args || "--silent" in Args)
      Options["silent"]
    if ("-x" in Args || "--tracing" in Args)
      Options["tracing"]
    if ("-t" in Args || "--timing" in Args)
      Options["timing"]
    #dbgA("ARGV", ARGV)
    #dbgA("Args", Args)
    #dbgA("ArgGoals", ArgGoals)
}

function dbgA(name, arr,    i) { print "--- " name ": "; for (i in arr) print i " : " arr[i] }

function splitKV(arg, kv,    n) {
  n = index(arg, "=")
  kv[0] = trim(substr(arg,1,n-1))
  kv[1] = trim(substr(arg,n+1))
}
function handleOptionDefineOverride(arg,    kv) {
  handleDefineLine(arg)
  splitKV(arg, kv)
  DefineOverrides[kv[0]] = kv[1]
}

function handleOptions() {
    checkPreludeOnly()

    for (i=2; i<=NF; i++) {
        if (!($i in SupportedOptions))
          die("Option " $i " is not supported")
        Options[$i]
    }
}

function handleDefine(    line,kv) {
    $1 = ""
    handleDefineLine($0)
}
function handleDefineLine(line,    kv) {
    checkPreludeOnly()

    if (!DefinesFile)
        DefinesFile = executeGetLine("mktemp /tmp/makesure.XXXXXXXXXX")

    splitKV(line, kv)

    if (!(kv[0] in DefineOverrides)) {
      handleCodeLine(line)
      handleCodeLine("echo " line " >> " DefinesFile)
    }
}

function handleShell() {
    checkPreludeOnly()

    Shell = trim($2)

    if (!(Shell in SupportedShells))
      die("Shell '" Shell "' is not supported")
}

function adjust_options() {
  if ("silent" in Options)
    delete Options["timing"]
}

function handleGoal(    goal_name) {
    if (isPrelude()) # 1st goal
      adjust_options()

    goal_name = trim($2)
    if (length(goal_name) == 0) {
        die("Goal must have a name")
    }
    if (goal_name in GoalsByName) {
        die("Goal " goal_name " is already defined")
    }
    arrPush(GoalNames, goal_name)
    GoalsByName[goal_name]
}

function handleDoc(    goal_name) {
    checkGoalOnly()

    goal_name = currentGoalName()

    $1 = ""
    Doc[goal_name, DocCnt[goal_name]++] = trim($0)
}

function handleDependsOn(    goal_name,i) {
    checkGoalOnly()

    goal_name = currentGoalName()

    for (i=2; i<=NF; i++) {
        Dependencies[goal_name, DependenciesCnt[goal_name]++] = $i
    }
}

function handleReachedIf(    goal_name) {
    checkGoalOnly()

    goal_name = currentGoalName()

    if (goal_name in ReachedIf) {
        die("Multiple " $1 " not allowed for a goal")
    }

    $1 = ""
    ReachedIf[goal_name] = trim($0)
}

function doWork(    i,j,goal_name,dep_cnt,dep,reached_if,reached_goals,empty_goals,my_dir,defines_line,
  body,goal_body,goal_bodies,resolved_goals,exit_code, t0,t1,t2, goal_timed) {

  if ("-l" in Args || "--list" in Args) {
      print "Available goals:"
      for (i = 0; i < arrLen(GoalNames); i++) {
          goal_name = GoalNames[i]
          print "  " goal_name
          if (goal_name in DocCnt) {
            for (j = 0; j < DocCnt[goal_name]; j++)
              print "    " Doc[goal_name, j]
          }
      }
  } else {
    if ("timing" in Options)
      t0 = currentTimeMillis()

    addLine(my_dir, "MYDIR='" getMyDir() "'")
    addLine(my_dir, "export MYDIR")
    addLine(my_dir, "cd \"$MYDIR\"")

    # run prelude first to process all @defines
    goal_body[0] = my_dir[0]
    if ("tracing" in Options)
        addLine(goal_body, "set -x")
    addLine(goal_body, trim(code[""]))
    exit_code = shellExec(goal_body[0])
    if (exit_code != 0)
      realExit(exit_code)

    addLine(defines_line, my_dir[0])
    if (DefinesFile) {
      addLine(defines_line, ". " DefinesFile)
    }

    for (i = 0; i < arrLen(GoalNames); i++) {
        goal_name = GoalNames[i]

        body = trim(code[goal_name])

        reached_if = ReachedIf[goal_name]
        reached_goals[goal_name] = reached_if ? checkConditionReached(defines_line[0], reached_if) : 0
        empty_goals[goal_name] = length(body) == 0

        # check valid dependencies
        dep_cnt = DependenciesCnt[goal_name]
        for (j=0; j < dep_cnt; j++) {
            dep = Dependencies[goal_name, j]
            if (!(dep in GoalsByName))
                dieMsg("Goal '" goal_name "' has unknown dependency '" dep "'") # TODO find a way to provide line reference
            if (!reached_goals[goal_name]) {
                # we only add a dependency to this goal if it's not reached
                #print " [not reached] " goal_name " -> " dep
                topologicalSortAddConnection(goal_name, dep)
            } else {
                #print " [    reached] " goal_name " -> " dep
            }
        }

        goal_body[0] = ""
        if (!("silent" in Options)) {
            addStr(goal_body, "echo \"  goal '" goal_name "' ")
            if (reached_goals[goal_name])
              addStr(goal_body, "[already satisfied].")
            else if (empty_goals[goal_name])
              addStr(goal_body, "[empty].")
            else
              addStr(goal_body, "...")
            addLine(goal_body, "\"")
        }
        if (reached_goals[goal_name])
            addLine(goal_body, "exit 0")

        addLine(goal_body, defines_line[0])

        if ("tracing" in Options)
            addLine(goal_body, "set -x")

        addLine(goal_body, body)
        goal_bodies[goal_name] = goal_body[0]
    }

    resolveGoalsToRun(resolved_goals)

    if ("-d" in Args || "--resolved" in Args) {
      printf("Resolved goals to reach for '%s':\n", join(ArgGoals, 0, arrLen(ArgGoals), " "))
      for (i = 0; i < arrLen(resolved_goals); i++) {
         print "  " resolved_goals[i]
      }
    } else {
      for (i = 0; i < arrLen(resolved_goals); i++) {
        goal_name = resolved_goals[i]
        goal_timed = "timing" in Options && !reached_goals[goal_name] && !empty_goals[goal_name]
        if (goal_timed)
          t1 = t2 ? t2 : currentTimeMillis()
        exit_code = shellExec(goal_bodies[goal_name])
        if (goal_timed) {
          t2 = currentTimeMillis()
          print "  goal '" goal_name "' took " renderDuration(t2 - t1)
        }
        if (exit_code != 0)
          break
      }
      if ("timing" in Options)
        print "  total time " renderDuration((t2 ? t2 : currentTimeMillis()) - t0)
      if (exit_code != 0)
        realExit(exit_code)
    }

    realExit(0)
  }
}

function resolveGoalsToRun(result,    i, goal_name, loop) {
    if (arrLen(ArgGoals) == 0)
        arrPush(ArgGoals, "default")

    for (i = 0; i < arrLen(ArgGoals); i++) {
        goal_name = ArgGoals[i]
        if (!(goal_name in GoalsByName)) {
            dieMsg("Goal not found: " goal_name) # TODO can we show line number here?
        }
        topologicalSortPerform(goal_name, result, loop)
    }

    if (loop[0] == 1) {
        dieMsg("There is a loop in goal dependencies via " loop[1] " -> " loop[2])
    }
}

function isPrelude() {
    return arrLen(GoalNames) == 0
}

function checkPreludeOnly() {
    if (!isPrelude()) {
        die("Only use " $1 " in prelude")
    }
}

function checkGoalOnly() {
   if (isPrelude()) {
       die("Only use " $1 " in goal")
   }
}

function currentGoalName() {
    return isPrelude() ? "" : GoalNames[arrLen(GoalNames)-1] # TODO arr_index via slice
}

function die(msg) {
    dieMsg(msg ":\n" ARGV[1] ":" NR ": " $0)
}

function realExit(code) {
    Died = 1
    if (DefinesFile)
      system("rm " DefinesFile)
    exit code
}
function dieMsg(msg,    out) {
    out = "cat 1>&2" # trick to write from awk to stderr
    print msg | out
    close(out)
    realExit(1)
}

function checkConditionReached(defines_line, condition_str,    script) {
    script = defines_line # need this to initialize variables for check conditions
    script = script "\n" condition_str
    #print "script: " script
    return shellExec(script) == 0
}

function shellExec(script,    s, res) {
    s = Shell " -e -c \"$(cat <<'MAKESURE_EOF'"
    s = s "\n" script
    s = s "\nMAKESURE_EOF\n)\""
    #print s
    res = system(s)
    #print "res " res
    return res
}

function getMyDir(    script) {
  script = Shell " -e <<'MAKESURE_EOF'"
  script = script "\n" sprintf("echo \"$(cd \"$(dirname %s)\"; pwd)\"", FILENAME)
  script = script "\nMAKESURE_EOF"
  return executeGetLine(script)
}

function handleCodeLine(line,    goal_name, current_code) {
    goal_name = currentGoalName()
    #print "Append line for '" goal_name "': " line
    current_code = code[goal_name]
    code[goal_name] = current_code ? current_code "\n" line : line
}

function topologicalSortAddConnection(from, to) {
    # Slist - list of successors by node
    # Scnt - count of successors by node
    Slist[from, ++Scnt[from]] = to # add 'to' to successors of 'from'
}

function topologicalSortPerform(node, result, loop,    i, s) {
    if (Visited[node] == 2)
        return

    Visited[node] = 1

    for (i = 1; i <= Scnt[node]; i++) {
        if (Visited[s = Slist[node, i]] == 0)
            topologicalSortPerform(s, result, loop)
        else if (Visited[s] == 1) {
            loop[0] = 1
            loop[1] = s
            loop[2] = node
        }
    }

    Visited[node] = 2

    arrPush(result, node)
}

function currentTimeMillis(    script, res) {
  res = executeGetLine("date +%s%3N")
  sub(/%3N/, "000", res) # if date doesn't support %N (macos?) just use second-precision
  return res + 0
}

function selfUpdate(    url, tmp, err, newVer) {
    url = "https://raw.githubusercontent.com/xonixx/makesure/main/makesure_stable"
    tmp = executeGetLine("mktemp /tmp/makesure_new.XXXXXXXXXX")
    err = dl(url, tmp)
    if (!err && 0 != system("chmod +x " tmp)) err = "can't chmod +x " tmp
    if (!err) {
        newVer = executeGetLine(tmp " -v")
        if (Version != newVer && 0 != system("cp " tmp " \"" Prog "\""))
            err = "can't overwrite " Prog
    }
    system("rm " tmp)
    if (err) dieMsg(err);
}

function renderDuration(deltaMillis,
#
deltaSec,deltaMin,deltaHr,deltaDay,
dayS,hrS,minS,secS,secSI,
res) {
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
function executeGetLine(script,    res) {
  script | getline res
  close(script)
  return res
}
function commandExists(cmd) { return system("which " cmd " >/dev/null 2>/dev/null") == 0 }
function dl(url, dest) {
    if (commandExists("wget") && 0 != system("wget \"" url "\" -O\"" dest "\""))
        return "error with wget"
    if (commandExists("curl") && 0 != system("curl \"" url "\" -o \"" dest "\""))
        return "error with curl"
    return "wget/curl no found"
}
function join(arr, start_incl, end_excl, sep,    result, i) {
    result = arr[start_incl]
    for (i = start_incl + 1; i < end_excl; i++)
        result = result sep arr[i]
    return result
}
function addStr(target, str) { target[0] = target[0] str }
function addLine(target, line) { addStr(target, line "\n") }
function arrPush(arr, elt) { arr[arr[-7]++] = elt }
function arrLen(arr) { return arr[-7] }
function isFile(path) { return system("test -f \"" path "\"") == 0 }
function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }
