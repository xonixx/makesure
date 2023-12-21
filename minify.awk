BEGIN { Q = "'" }

/^BEGIN/                  { in_begin = 1 }
in_begin && /^}/          { in_begin = 0 }
in_begin && $1 ~ /^delete/{ next }
{ minifyLine() }

function minifyLine(   l) {
  if (!/"#"/ && !/\*#\// && !/\*\(#/) gsub("[ \t\r\n]*#.*$", "")
  gsub(/ == /, "==")
  gsub(/ = /, "=")
  gsub(/ != /, "!=")
  gsub(/ >= /, ">=")
  gsub(/ <= /, "<=")
  gsub(/; +/, ";")
  gsub(/ ~ /, "~")
  gsub(/ > /, ">")
  gsub(/ < /, "<")
  gsub(/ \/ /, "/")
  gsub(/ \* /, "*")
  gsub(/ \+ /, "+")
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
  gsub(/print +"/, "print\"")
  gsub(/printf +"/, "printf\"")
  if (!/^ +}/) gsub(/ +}/, "}")
  gsubKeepStrings(", +", ",")
  gsubKeepStrings(" *- ", "-")
  gsubKeepStrings("] +", "]")
  gsubKeepStrings("^ +in ", "in ")
  gsubKeepStrings(" +$", "")
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
    if ("\"" == c && (substr($0,i-1,1) != "\\" || substr($0,i-2,1) == "\\")) {
      if (!isString) {
        gsub(regex, replacement, nonString)
        s = s nonString
        nonString = ""
      } else {
        # skip whitespaces after "
        while (substr($0,i+1,1) == " ") i++
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
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
#BEGIN { $0 = "aaa\"aaa\"bbbaaa"; gsubKeepStrings("aaa","AAA"); print }
#BEGIN { $0 = "aaa\"aaa\\\"aaa\"bbbaaa"; gsubKeepStrings("aaa","AAA"); print }
#BEGIN { $0 = "if (\"-h\" in Args || \"--help\" in Args) {"; gsubKeepStrings("^ +in", "in"); print }
#BEGIN { $0 = "      if (arg == \"-f\" || arg == \"--file\") {"; minifyLine() }
#BEGIN { $0 = "    res = dayS \" \" (hrS == \"\" ? \"0 h\" : hrS)"; minifyLine() }
#BEGIN { $0 = "  quicksort(GlobFiles, 0, arrLen(GlobFiles) - 1)"; minifyLine() }
