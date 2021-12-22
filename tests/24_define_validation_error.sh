
@define echo
@define echo 'Hello'
@define A=aaa echo 'Hello'
@define B=aaa\ aaa echo 'Hello'
@define C='aaa aaa' echo 'Hello'

@goal default
  echo 'Should not show'

