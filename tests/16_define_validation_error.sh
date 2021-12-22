
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

# Let's disallow ';' for simplicity and unification
@define B3='bbb ; bbb';
@define B4='bbb ; bbb'    ;
@define BC3='bbb bbb';  # comment
@define BC4='bbb ; bbb'   ;  # comment

# Illegal chars. This is more restrictive than shell but simpler to parse
@define IL1=a||b
@define IL2=a&b
@define IL3=a&&b
@define IL4=a!b
@define IL5=a-b
@define IL5=a+b

@goal default
  echo 'Should not show'

