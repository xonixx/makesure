# vim: syntax=bash

_makesure_completions() {
  local i cur prev cnt makesurefile=Makesurefile

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  cnt="${#COMP_WORDS[@]}"

  if [[ "$prev" == '-f' || "$prev" == '--file' ]]
  then
    COMPREPLY=() # use regular completion logic to facilitate file/folder selection
    return 0
  fi

  # before we scan for targets, see if a Makesurefile name was
  # specified with -f/--file
  for ((i = 1; i < cnt; i++)); do
      if [[ ${COMP_WORDS[i]} == '-f' || ${COMP_WORDS[i]} == '--file' ]]; then
          eval "makesurefile=${COMP_WORDS[i + 1]}"
          break
      fi
  done

  local exe="${COMP_WORDS[0]}"
  COMPREPLY=($(compgen -W "$("$exe" --file "$makesurefile" -la | awk -F: '
BEGIN {
  print "-f --file"
  print "-l --list"
  print "-la --list-all"
  print "-d --resolved"
  print "-D"
  print "-s --silent"
  print "-t --timing"
  print "-x --tracing"
  print "-v --version"
  print "-h --help"
  print "-U --selfupdate"
}
NR>1 { sub(/^ +/,"",$1); print $1 }
')" -- "$cur"))
}

complete -F _makesure_completions -o bashdefault -o default ./makesure ../makesure
