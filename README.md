# makesure

[![Run tests](https://github.com/xonixx/makesure/workflows/Run%20tests/badge.svg)](https://github.com/xonixx/makesure/actions?query=workflow%3A%22Run+tests%22)

Simple bash-based build tool a-la make with declarative goals and dependencies.

The simplest way to think of this tool is to have a way to have "shortcuts" (aka goals) to some pieces of scripts. This way allows to call them easily without the need to call long shell one-liners instead.

Example `Makesurefile`:

```bash
@goal downloaded
@reached_if [[ -f code.tar.gz ]]
  wget http://domain/code.tar.gz
  
@goal extracted
@depends_on downloaded
  tar xzf code.tar.gz 

@goal built
@depends_on extracted
  npm install
  npm run build

@goal deployed
  scp -C -r build/* user@domain:~/www

@goal default
@depends_on deployed
```

Now to run the whole build you just issue `makesure` command in a folder with `Makesurefile` (`default` goal will be called). 

You can as well call single goal explicitly, example `makesure built`. 

Also pay attention to `@reached_if` directive. This one allows skipping goal if it's already satisfied. This allows to speedup subsequent calls.