
#@options tracing

@define AWK="${AWK:-awk}"
@define D='/tmp/dirXXX with spaces'
#@define D='/tmp/dirXXX'

@goal makesure_prepared
  [[ -d "$D" ]] && rm -r "$D"
  mkdir "$D"
  cp "../$MAKESURE" ../makesure.awk "$D"

  export NEXT_VERSION=XXX
  if [[ "$("$D/$MAKESURE" --version)" != "XXX" ]]
  then
    # this is compiled version
    awk '/^exec/ { sub(/Version=[0-9.]+/,"Version=XXX") } 1' "$D/$MAKESURE" > "$D/$MAKESURE"_1
    cat "$D/$MAKESURE"_1 > "$D/$MAKESURE"
    rm "$D/$MAKESURE"_1
  fi

  for cmd in awk mktemp rm cp dirname cat chmod
  do
    if [[ $cmd == 'awk' && $AWK != 'awk' ]]
    then
      cmd1=$AWK
    else
      cmd1=`command -v $cmd`
    fi
    {
      echo "#!/bin/sh"
      echo "exec $cmd1 \"\$@\""
    } > "$D/$cmd"
    chmod +x "$D/$cmd"
  done

@lib
  function run_selfupdate() {
    export PATH="$D"
    export NEXT_VERSION=XXX
    "$D/$MAKESURE" --version
    "$D/$MAKESURE" --selfupdate
    "$D/$MAKESURE" --selfupdate
    "$D/$MAKESURE" --version
    rm -r "$D"
  }

@goal test_err
@depends_on makesure_prepared
@use_lib
  run_selfupdate

@goal test_wget
@depends_on wget_prepared
@use_lib
  run_selfupdate

@goal test_curl
@depends_on curl_prepared
@use_lib
  run_selfupdate

# TODO is it possible to test via native wget if available?
@goal wget_prepared
@depends_on makesure_prepared
  cmd="wget"

  echo $'#!/bin/sh
echo "running wget"
# fake wget with curl
exec awk -v CURL="'$(command -v curl)$'" -v a1="$1" -v a2="$2" -v a3="$3" \'
BEGIN {
sub(/-q/,"-s",a1)
sub(/-O/,"-o",a3)
system(CURL " " a1 " " a2 " " a3)
}\'
' > "$D/$cmd"

  chmod +x "$D/$cmd"

@goal curl_prepared
@depends_on makesure_prepared
  cmd="curl"
  cmd1=`command -v $cmd`
  {
    echo "#!/bin/sh"
    echo 'echo "running curl"'
    echo "exec $cmd1 \"\$@\""
  } > "$D/$cmd"
  chmod +x "$D/$cmd"
