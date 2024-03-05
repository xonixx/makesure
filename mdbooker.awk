BEGIN {
  printf "" > (SUMMARY = (BOOK = "book/") "SUMMARY.md")
  H = 0
  Title = Content = ""
  delete PathElements
}

/^# /    { handleTitle(1); next }
/^## /   { handleTitle(2); next }
/^### /  { handleTitle(3); next }
/^#### / { handleTitle(4); next }
/^#####/ { print "error: #####"; exit 1 }
{ Content = Content "\n" $0; next }

function handleTitle(h,   md,indent,dir,i,path) {
  if (Title) {
    for (i = 2; i < H; i++)
      dir = dir (dir ? "/" : "") fname(PathElements[i])
    print "generating: " (path = dir (dir ? "/" : "") (md = fname(Title) ".md")) "..."
    if (dir)
      system("mkdir -p '" BOOK dir "'")
    print Content > BOOK path
    if ((indent = H - 2) < 0)
      indent = 0
    printf "%" (indent * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "- ", Title, path >> SUMMARY
  }
  Content = "# " (Title = PathElements[H = h] = trim(substr($0, h + 1)))
}

END { handleTitle(-1) }

function fname(s) { gsub(/ /, "_", s); return s }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
