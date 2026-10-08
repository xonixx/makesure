
#@options tracing

@define MAKESURE_AWK "${MAKESURE_AWK:-awk}" # XXX Crazy! This comes by implicit export via the PG param in Makesurefile
@define D            '/tmp/dirXXX with spaces'
#@define D '/tmp/dirXXX'
@define MAKESURE_PROG 'DEFINE_ME'

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
    local ver="$1"
    /usr/bin/awk -v ver="$ver" \
     '
     { gsub(/-v "Version=[^"]+"/, "-v \"Version="ver"\"") } 1
     ' "../$MAKESURE_PROG" > "$D/$MAKESURE_PROG"
#    cat "$D/$MAKESURE_PROG"
    chmod +x "$D/$MAKESURE_PROG"
    cp ../*.awk "$D"
  }
  function run_selfupdate() {
    export PATH="$D"

    local prevVer=$(../makesure -v)
    # calc by subtracting 1
    prevVer=$(/usr/bin/awk -v prevVer="$prevVer" 'BEGIN { split(prevVer,parts,"."); print parts[1]"."parts[2]"."(--parts[3]) }')

    prepare_makesure "$prevVer"
    "$D/$MAKESURE_PROG" --version
    echo 'selfupdate 1'
    "$D/$MAKESURE_PROG" --selfupdate

    local latestVersion="$("$D/$MAKESURE_PROG" --version)"
    prepare_makesure "$latestVersion"
    echo 'selfupdate 2'
    "$D/$MAKESURE_PROG" --selfupdate
    "$D/$MAKESURE_PROG" --version
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
