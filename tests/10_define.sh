

@define A=aaa
@define B=${A}bbb
C=ccc

@goal testA
echo A=$A

@goal testB
echo B=$B

@goal testC
echo C=$C

@goal testABC
@depends_on testA testB testC
