BEGIN {
  BOOK = "book"
  SUMMARY = BOOK "/SUMMARY.md"
  printf "" > SUMMARY
  H = 0
  Title = ""
  Content = ""
  delete PathElements
}

/^# /    { handleTitle(1); next }
/^## /   { handleTitle(2); next }
/^### /  { handleTitle(3); next }
/^#### / { print "error: ####"; exit 1 }
{ Content = Content $0 "\n"; next }

function handleTitle(h,   md,indent,dir,i,path) {
  if (Title) {
    md = fname(Title) ".md"
    dir = ""
    for (i=2; i<H; i++) {
      dir = dir (dir ? "/" : "") fname(PathElements[i])
    }
    path = dir (dir ? "/" : "") md
    print "generating: " path "..."
    if (dir) system("mkdir -p '" BOOK "/" dir "'")
    print "# " Title > BOOK "/" path
    print Content >> BOOK "/" path
    indent = H - 2
    if (indent < 0)
      indent = 0
    printf "%" (indent * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "- ", Title, path >> SUMMARY
  }
  PathElements[H = h] = Title = trim(substr($0, h + 1))
  Content = ""
}

END { handleTitle(-1) }

function fname(s) { gsub(/ /, "_", s); return s }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
