BEGIN {
  BOOK = "book"
  SUMMARY = BOOK "/SUMMARY.md"
  printf "" > SUMMARY
  H = 0
  Title = ""
  Content = ""
}

/^# /    { handleTitle(1); next }
/^## /   { handleTitle(2); next }
/^### /  { handleTitle(3); next }
/^#### / { print "error: ####"; exit 1 }
{ Content = Content $0 "\n"; next }

function handleTitle(h,   md,indent,fname) {
  if (Title) {
    fname = Title
    gsub(/ /, "_", fname)
    md = fname ".md"
    print "generating: " md "..."
    print "# " Title > BOOK "/" md
    print Content >> BOOK "/" md
    indent = H - 2
    if (indent < 0)
      indent = 0
    printf "%" (indent * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "- ", Title, md >> SUMMARY
  }
  H = h
  Title = trim(substr($0, h + 1))
  Content = ""
}

END { handleTitle(-1) }

function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
