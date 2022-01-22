# vim: syntax=bash

_makesure_completions() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  #echo ">> $cur :: $prev"

  # DONE auto-complete goals
  # TODO auto-complete options
  # TODO auto-complete goals from correct file (-f)

  COMPREPLY=($(compgen -W "$(./makesure -la | awk -F: 'NR>1 { sub(/^ +/,"",$1);print $1 }')" -- "$cur"))
}

complete -F _makesure_completions -o bashdefault -o default ./makesure
