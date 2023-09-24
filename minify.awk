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
  gsub(/print +"/,"print\"")
  gsub(/printf +"/,"printf\"")
  if (!/^ +}/) gsub(/ +}/, "}")
  ##gsub(/" in/, "\"in")
  gsub(Q, Q "\\" Q Q)
  if (l = trim($0)) { printf "%s", (l == "}" ? l : (NR == 1 ? "" : "\n") $0) }
}
function gsubKeepStrings(regex, replacement,   cnt,parts,i,s) {
  if ((cnt = split($0,parts,"\"")) == 1) {
    gsub(regex,replacement)
    return
  }
  gsub(regex,replacement,parts[1])
  gsub(regex,replacement,parts[cnt])
  for (i = 1; i < cnt; i++)
    s = s parts[i] "\""
  s = s parts[cnt]
  $0 = s
}
#BEGIN { $0 = "aaa\"aaa\"bbb"; gsubKeepStrings("aaa","AAA"); print }