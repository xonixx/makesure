#!/usr/bin/env bash

a="hello"

m1() {
  echo "$a, $b"
}

m2() {
  b="world"
  (
  echo "subshell"
  m1
  exit 1
  )

    echo "$?"

  m1
}

@m3() {
  echo "qewqqe @m3"
}

#m2
#@m3

export a=4567
#a=4567

fff() {
  echo "FFF"
}
export fff


bash << 'EOF'

echo "111"
echo "a=$a"
echo "fff=$fff"
export c=CCCCC

EOF

bash << 'EOF'

echo "222"
echo "c=$c"

EOF


#@define() {
#  echo "define \$1=$1"
#  echo "define \$2=$2"
#}
#
#@define a
#@define b=BBB
#echo $b
#export b=BBB
#echo $b