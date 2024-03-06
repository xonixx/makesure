BEGIN {
  printf "" > (SUMMARY = (BOOK = "book/") "SUMMARY.md")
  H = 0
  Title = Content = ""
  delete PathElements
  delete Link2Path
}

match($0, /^#+/) { handleTitle(RLENGTH, 1) }

function handleTitle(h,pass,   md,indent,dir,i,path) {
  if (Title) {
    for (i = 2; i < H; i++)
      dir = dir (dir ? "-" : "") fname(PathElements[i])
    path = dir (dir ? "-" : "") (md = fname(Title) ".md")
    if (pass == 1) {
      Link2Path[linkify(Title)] = path
    } else {
      print "generating: " path "..."
      print Content > BOOK path
      if ((indent = H - 2) < 0)
        indent = 0
      printf "%" (indent * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "- ", Title, path >> SUMMARY
    }
  }
  Content = "# " (Title = PathElements[H = h] = trim(substr($0, h + 1)))
}

END { handleTitle(-1, 1); pass2() }

function pass2(   l,f,t) {
  Title = Content = ""
  while (getline < FILENAME > 0) {
    if (match($0, /^#+/))
      handleTitle(RLENGTH, 2)
    else {
      if (match(l = $0, /]\(#[^)]+\)/)) {
        print "  fix link: #" (f=substr(l, RSTART + 3, RLENGTH - 4)) " -> " (t = Link2Path[f])
        l = substr(l, 1, RSTART - 1) "](" t ")" substr(l, RSTART + RLENGTH)
      }
      Content = Content "\n" l
    }
  }
  handleTitle(-1, 2)
}

function linkify(t) { t = tolower(t); gsub(/ /, "-", t); gsub(/[^-a-z0-9_]/, "", t); return t }
function fname(s) { gsub(/ /, "_", s); return s }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
