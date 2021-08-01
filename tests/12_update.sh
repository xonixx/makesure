
#@define D='/tmp/dir with spaces'
@define D='/tmp/dirXXX'
@define makesure_stableXXX="$D/makesure_stableXXX"

@goal test_dir_recreated
  [[ -d "$D" ]] && rm -r "$D"
  mkdir "$D"

@goal makesure_stableXXX_prepared
  awk '{ if (/^VERSION="/) print "VERSION=\"XXX\""; else print }' ../makesure_stable > "$makesure_stableXXX"
  chmod +x "$makesure_stableXXX"
  for cmd in which awk mktemp rm cp cat chmod
  do
    ln -s `which $cmd` "$D/$cmd"
  done

@goal run_selfupdate
  export PATH="$D"
  "$makesure_stableXXX" --version
  "$makesure_stableXXX" --selfupdate
  "$makesure_stableXXX" --version
  rm -r "$D"

@goal test_err
  @depends_on test_dir_recreated
  @depends_on makesure_stableXXX_prepared
  @depends_on run_selfupdate

@goal test_wget
  @depends_on test_dir_recreated
  @depends_on makesure_stableXXX_prepared
  @depends_on wget_prepared
  @depends_on run_selfupdate

@goal test_curl
  @depends_on test_dir_recreated
  @depends_on makesure_stableXXX_prepared
  @depends_on curl_prepared
  @depends_on run_selfupdate

@goal wget_prepared
  ln -s `which wget` "$D/wget"

@goal curl_prepared
  ln -s `which curl` "$D/curl"
