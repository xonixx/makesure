# vim: syntax=bash

_makesure_completions() {
  local i cur prev cnt
  #COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  cnt="${#COMP_WORDS[@]}"
  #echo ">> $cur :: $prev :: $COMP_CWORD"

  # DONE auto-complete goals
  # DONE auto-complete options
  # TODO auto-complete goals from correct file (-f)

#  for ((i=0; i<#COMP_WORDS[@]))
#  do
#
#  done

  echo "@@ ${#COMP_WORDS[@]} @@ $COMP_CWORD"
  for i in ${COMP_WORDS[@]}
  do
    echo ">> $i"
  done
  

  if [[ "$prev" == '-f' || "$prev" == '--file' ]]
  then
    COMPREPLY=() # use regular completion logic to facilitate file/folder selection
    return 0
  fi

  COMPREPLY=($(compgen -W "$(./makesure -la | awk -F: '
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
