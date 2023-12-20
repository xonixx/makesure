BEGIN { Q = "'" }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
/^BEGIN/                  { in_begin = 1 }
in_begin && /^}/          { in_begin = 0 }
in_begin && $1 ~ /^delete/{ next }
{ if (!/"#"/ && !/\*#\// && !/\*\(#/) gsub("[ \t\r\n]*#.*$", "")
  gsub(/ == /, "==")
  gsub(/ = /, "=")
  gsub(/ != /, "!=")
  gsub(/ >= /, ">=")
  gsub(/ <= /, "<=")
  gsub(/; +/, ";")
  gsubKeepStrings(", +", ",")
  gsub(/ ~ /, "~")
  gsub(/ > /, ">")
  gsub(/ < /, "<")
  gsub(/ \/ /, "/")
  gsub(/ \* /, "*")
  gsub(/ \+ /, "+")
  gsubKeepStrings(" - ", "-")
  gsub(/ \|\| /, "||")
  gsub(/ \| /, "|")
  if (/ \? /) gsub(/ : /, ":")
  gsub(/ \? /, "?")
  gsub(/if \(/, "if(")
  gsub(/for \(/, "for(")
  gsub(/while \(/, "while(")
  gsub(/ && /, "\\&\\&")
  gsub(/[)] [{]/, "){")
  gsub(/\( +/, "(")
  gsub(/[{] +/, "{")
  gsub(/} +/, "}")
  gsub(/[)] +/, ")")
  gsubKeepStrings("] +", "]")
  gsub(/print +"/, "print\"")
  gsub(/printf +"/, "printf\"")
  if (!/^ +}/) gsub(/ +}/, "}")
  gsubKeepStrings("^ +in ", "in ")
  gsub(Q, Q "\\" Q Q)
  if (l = trim($0)) { decreaseIndent(); printf "%s", (l == "}" ? l : (NR == 1 ? "" : "\n") $0) }
}
function decreaseIndent() {
  match($0, /^ */)
  $0 = sprintf("%" (RLENGTH - 1) / 2 "s", "") substr($0, RLENGTH)
}
function gsubKeepStrings(regex, replacement,   nonString,s,isString,i,c) {
  nonString = ""
  s = ""
  isString = 0
  for (i=1;(c=substr($0,i,1))!="";i++) {
#    print "> " i " " c
    if ("\"" == c) {
      # TODO escaped "
      if (!isString) {
        gsub(regex, replacement, nonString)
        s = s nonString
        nonString = ""
      }
      s = s c # append this "
      isString = !isString
    } else if (isString) {
      s = s c
    } else {
      nonString = nonString c
    }
  }
  gsub(regex, replacement, nonString)
  s = s nonString
  $0 = s
}
#BEGIN { $0 = "aaa\"aaa\"bbbaaa"; gsubKeepStrings("aaa","AAA"); print }
#BEGIN { $0 = "if (\"-h\" in Args || \"--help\" in Args) {"; gsubKeepStrings("^ +in", "in"); print }