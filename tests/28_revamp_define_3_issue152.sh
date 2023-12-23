
# see https://github.com/xonixx/makesure/issues/152

@define AAA 'aaa'

@goal g
@depends_on pg @args "$AAA"
@depends_on pg @args "$BBB"

# define goes after the reference above
@define BBB 'bbb'

@goal pg @params V
  echo "$V"