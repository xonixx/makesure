
@define A=aaa
@define B='bbb'
@define C=$'cc\'c'
@define D=a\ b\ c
@define E="eee"

@define K=aaa'bbb'$'cc\'c'a\ b\ c"eee"
@define L="$A$B$C$D$E"

@define A1=aaa          # comment
@define A2=aaa#         # comment
@define B1='bbb'  # comment
@define B2='bbb'#  # comment
@define C1=$'cc\'c'  #
@define D1=a\ b\ c #
@define E1="eee"  # comment

@define K1=aaa'bbb'$'cc\'c'a\ b\ c"eee" # some comment
@define L1="$A$B$C$D$E"                 # other comment

@goal default
  for x in A B C D E K L A1 A2 B1 B2 C1 D1 E1 K1 L1
  do
    echo "$x=${!x}"
  done

