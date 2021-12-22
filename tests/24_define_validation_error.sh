
@define echo
@define echo;
@define echo;echo
@define echo ; echo
@define echo 'Hello'
@define echo 'Hello';
@define A=aaa echo 'Hello'
@define B=aaa\ aaa echo 'Hello'
@define C='aaa aaa' echo 'Hello'

@define echo                       # comment
@define echo 'Hello'           # comment
@define echo 'Hello';           # comment
@define echo 'Hello'  ;# comment
@define A=aaa echo 'Hello'        # comment
@define B=aaa\ aaa echo 'Hello'# comment
@define C='aaa aaa' echo 'Hello' # comment
@define C='aaa aaa' echo 'Hello' ; # comment

@goal default
  echo 'Should not show'

