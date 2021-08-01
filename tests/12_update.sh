
#@define D='/tmp/dir with spaces'
@define D='/tmp/dirXXX'
@define makesure_stableXXX="$D/makesure_stableXXX"

@goal test1
  mkdir "$D"
  awk '{ if (/^VERSION="/) print "VERSION=\"XXX\""; else print }' ../makesure_stable > "$makesure_stableXXX"
  chmod +x "$makesure_stableXXX"
  "$makesure_stableXXX" --version
  "$makesure_stableXXX" --selfupdate
  "$makesure_stableXXX" --version
  rm -r "$D"

