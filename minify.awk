BEGIN { Q="'" }
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
  gsub(/, +/, ",")
  gsub(/ ~ /, "~")
  gsub(/ > /, ">")
  gsub(/ < /, "<")
  gsub(/ \/ /, "/")
  gsub(/ \* /, "*")
  gsub(/ \+ /, "+")
  ##gsub(/ - /, "-")
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
  ##gsub(/] +/, "]")
  if (!/^ +}/) gsub(/ +}/, "}")
  ##gsub(/" in/, "\"in")
  gsub(Q, Q "\\" Q Q)
  if (l = trim($0)) { printf "%s", (l == "}" ? l : (NR == 1 ? "" : "\n") $0) }
}