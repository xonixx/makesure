
#@options tracing

@define MAKESURE_AWK "${MAKESURE_AWK:-awk}"
@define D            '/tmp/dirXXX with spaces'
#@define D '/tmp/dirXXX'

@goal env_prepared
  [[ -d "$D" ]] && rm -r "$D"
  mkdir "$D"

  for cmd in awk mktemp rm cp dirname cat chmod
  do
    if [[ $cmd == 'awk' && $MAKESURE_AWK != 'awk' ]]
    then
      cmd1=$MAKESURE_AWK
    else
      cmd1=$(command -v $cmd)
    fi
    {
      echo "#!/bin/sh"
      echo "exec $cmd1 \"\$@\""
    } > "$D/$cmd"
    chmod +x "$D/$cmd"
  done

@lib
  function prepare_makesure() {
    awk -v X="$(cd ..; pwd)" '/AWK_DIR=/{ $0 = "AWK_DIR=" X } 1' "../$MAKESURE" > "$D/$MAKESURE"
    chmod +x "$D/$MAKESURE"
  }
  function run_selfupdate() {
    export PATH="$D"

    prepare_makesure
    export NEXT_VERSION=0.9.22 # TODO calc by subtracting 1
    "$D/$MAKESURE" --version
    echo 'selfupdate 1'
    "$D/$MAKESURE" --selfupdate

    local latestVersion="$("$D/$MAKESURE" --version)"
    prepare_makesure
    export NEXT_VERSION="$latestVersion"
    echo 'selfupdate 2'
    "$D/$MAKESURE" --selfupdate
    "$D/$MAKESURE" --version
    rm -r "$D"
  }

@goal test_err
@depends_on env_prepared
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

@goal wget_prepared
@depends_on env_prepared
  cmd="wget"
  cmd1=`command -v $cmd`
  {
    echo "#!/bin/sh"
    echo 'echo "running wget"'
    echo "exec $cmd1 \"\$@\""
  } > "$D/$cmd"
  chmod +x "$D/$cmd"

@goal curl_prepared
@depends_on env_prepared
  cmd="curl"
  cmd1=`command -v $cmd`
  {
    echo "#!/bin/sh"
    echo 'echo "running curl"'
    echo "exec $cmd1 \"\$@\""
  } > "$D/$cmd"
  chmod +x "$D/$cmd"
