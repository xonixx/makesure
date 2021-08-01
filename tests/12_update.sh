
#@define D='/tmp/dir with spaces'
@define D='/tmp/dirXXX'
@define makesure_stableXXX="$D/makesure_stableXXX"

@goal test1
  [[ -d "$D" ]] && rm -r "$D"
  mkdir "$D"
  awk '{ if (/^VERSION="/) print "VERSION=\"XXX\""; else print }' ../makesure_stable > "$makesure_stableXXX"
  chmod +x "$makesure_stableXXX"
  ln -s `which which` "$D/which"
  ln -s `which awk` "$D/awk"
  ln -s `which mktemp` "$D/mktemp"
  ln -s `which rm` "$D/rm"
  ln -s `which cat` "$D/cat"
  export PATH="$D"
  "$makesure_stableXXX" --version
  "$makesure_stableXXX" --selfupdate
  "$makesure_stableXXX" --version
  rm -r "$D"

