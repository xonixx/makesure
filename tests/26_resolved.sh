
# https://github.com/xonixx/makesure/issues/29#issuecomment-1032932835

@goal a
@reached_if [[ $REACHED == *a* ]]
@depends_on b c
	echo a

@goal b
@reached_if [[ $REACHED == *b* ]]
	echo b

@goal c
@reached_if [[ $REACHED == *c* ]]
	echo c