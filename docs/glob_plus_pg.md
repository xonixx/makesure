
```shell
@goal gpg @glob 'glob_test/*.txt' @params P
  echo "$ITEM $P"

@goal g1
@depends_on gpg @args 'hello'
```

->

```shell
@goal gpg @params P
@depends_on 'gpg@glob_test/1.txt' @args P 
@depends_on 'gpg@glob_test/2.txt' @args P 

@goal 'gpg@glob_test/1.txt' @params P
  echo "$ITEM $P"
@goal 'gpg@glob_test/2.txt' @params P
  echo "$ITEM $P"

@goal g1
@depends_on gpg @args 'hello'
```
