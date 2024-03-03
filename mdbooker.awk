BEGIN {
  OUTDIR = "book"
  SUMMARY = OUTDIR "/SUMMARY.md"
  printf "" > SUMMARY
  N = 0
  H = 0
  Title = ""
  Content = ""
}

/^# /    { handleTitle(1); next }
/^## /   { handleTitle(2); next }
/^### /  { handleTitle(3); next }
/^#### / { print "error: ####"; exit 1 }
{ Content = Content $0 "\n"; next }

function handleTitle(h,   md) {
  if (Title) {
    N++
    md = (N < 10 ? "0": "") N "_" Title ".md"
    print "generating: " md "..."
    print Content > OUTDIR "/" md
    printf "%" ((H - 1) * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "-", Title, md >> SUMMARY
  }
  H = h
  Title = trim(substr($0, h+1))
  Content = ""
}

END { handleTitle(-1) }

function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
