
#@define D='/tmp/dirXXX with spaces'
@define D='/tmp/dirXXX'

@goal makesure_prepared
  [[ -d "$D" ]] && rm -r "$D"
  mkdir "$D"
  cp ../makesure ../makesure.awk "$D"
  for cmd in which awk mktemp rm cp dirname cat chmod
  do
    ln -s `which $cmd` "$D/$cmd"
  done

@goal run_selfupdate
  export PATH="$D"
  export NEXT_VERSION=XXX
  "$D/makesure" --version
  "$D/makesure" --selfupdate
  "$D/makesure" --version
  rm -r "$D"

@goal test_err
  @depends_on makesure_prepared
  @depends_on run_selfupdate

@goal test_wget
  @depends_on makesure_prepared
  @depends_on wget_prepared
  @depends_on run_selfupdate

@goal test_curl
  @depends_on makesure_prepared
  @depends_on curl_prepared
  @depends_on run_selfupdate

@goal wget_prepared
  ln -s `which wget` "$D/wget"

@goal curl_prepared
  ln -s `which curl` "$D/curl"
