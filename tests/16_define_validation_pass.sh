
@define EMPTY  ''
@define EMPTY1 ''
@define EMPTY2 $''
@define EMPTY3 ""
@define _a123 123
@define good__NaMe_ 123
@define A aaa
@define B 'bbb bbb'
@define B1 'bbb # bbb'
@define B2 'bbb ; bbb'
@define C $'cc\'c  cc\'c'
@define C1 "$C"
@define D $'a b  c'
@define D1 abcd
@define D2 $'a\'c"'
@define E "eee eee"
@define F "eee \\ \" eee"

@define K $'aaabbbcc\'ca b  ceee'
@define L "$A$B $C$D  $E"

@define AC1 aaa          # comment
@define AC2 'aaa#'         # comment
@define BC1 'bbb bbb'  # comment
@define BC2 'bbb bbb#'  # comment
@define CC1 $'cc\'c  cc\'c'  #
@define DC1 'a b c' #
@define EC1 "eee"  # comment

@define KC1 $'aaabbbcc\'ca b  ceee'      # some comment
@define LC1 "$A$B$C$D$E"                 # other comment

@define IL5 a-b

@goal default
  for x in EMPTY EMPTY1 EMPTY2 EMPTY3 _a123 good__NaMe_ A B B1 B2 C C1 D D1 D2 E F K L AC1 AC2 BC1 BC2 CC1 DC1 EC1 KC1 LC1 IL5
  do
    printf '%-3s=%s\n' "$x" "${!x}"
  done

