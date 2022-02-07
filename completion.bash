# vim: syntax=bash

_makesure_completions() {
  local i cur prev cnt makesurefile=Makesurefile

  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  cnt="${#COMP_WORDS[@]}"
  #echo ">> $cur :: $prev :: $COMP_CWORD"

  # DONE auto-complete goals
  # DONE auto-complete options
  # DONE auto-complete goals from correct file (-f)

  if [[ "$prev" == '-f' || "$prev" == '--file' ]]
  then
    COMPREPLY=() # use regular completion logic to facilitate file/folder selection
    return 0
  fi

  # before we scan for targets, see if a Makesurefile name was
  # specified with -f/--file
  for ((i = 1; i < ${#COMP_WORDS[@]}; i++)); do
      if [[ ${COMP_WORDS[i]} == '-f' || ${COMP_WORDS[i]} == '--file' ]]; then
          # eval for tilde expansion
#          echo
#          printf 'f=%s\n' "${COMP_WORDS[i + 1]}"
          eval "makesurefile=${COMP_WORDS[i + 1]}"
          break
      fi
  done

#  echo
#  echo "makesurefile=$makesurefile"

  COMPREPLY=($(compgen -W "$(./makesure --file "$makesurefile" -la | awk -F: '
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

complete -F _makesure_completions -o bashdefault -o default ./makesure
