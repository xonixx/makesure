BEGIN {
  Repo = ENVIRON["REPO"]
  LinkBase = "https://github.com/" Repo "/blob/main/"
  RawBase = "https://github.com/" Repo "/raw/main/"
  printf "" > (SUMMARY = (BOOK = "book/") "SUMMARY.md")
  H = 0
  Title = Content = ""
  delete PathElements
  delete Link2Path
  delete ContentLinks
}

match($0, /^#+/) { handleTitle(RLENGTH, 1) }

function handleTitle(h,pass,   indent,dir,i,path,title) {
  title = trim(substr($0, h + 1))
  if (Title) {
    for (i = 2; i < H; i++)
      dir = dir (dir ? "-" : "") fname(PathElements[i])
    path = dir (dir ? "-" : "") fname(Title) ".md"
    if (pass == 1) {
      Link2Path[linkify(Title)] = path
      if (H > 2)
        ContentLinks[PathElements[H - 1]] = ContentLinks[PathElements[H - 1]] "- [" Title "](" path ")\n"
    } else {
      print "generating: " path "..."
      if (!(Content = trim(Content))) {
        Content = ContentLinks[Title]
      }
      print "# " Title > BOOK path
      print Content >> BOOK path
      if ((indent = H - 2) < 0)
        indent = 0
      printf "%" (indent * 4) "s%s[%s](%s)\n", "", 1 == H ? "" : "- ", Title, path >> SUMMARY
    }
  } else
    print Content > BOOK fname(title) ".md" # pre-content
  Content = ""
  Title = PathElements[H = h] = title
}

END { handleTitle(0, 1); pass2() }

function pass2(   l,f,t) {
  Title = Content = ""
  while (getline < FILENAME > 0) {
    if (match($0, /^#+/))
      handleTitle(RLENGTH, 2)
    else {
      if (match(l = $0, /]\(#[^)]+\)/)) {
        print "  fix #link: #" (f = substr(l, RSTART + 3, RLENGTH - 4)) " -> " (t = Link2Path[f])
        l = substr(l, 1, RSTART - 1) "](" t ")" substr(l, RSTART + RLENGTH)
      } else if (match(l, /]\([^)]+\)/) && (f = substr(l, RSTART + 2, RLENGTH - 3)) !~ /https?:/) {
        if (l ~ /!\[/)
          print "  fix image link: " f " -> " (t = RawBase f)
        else
          print "  fix relative link: " f " -> " (t = LinkBase f)
        l = substr(l, 1, RSTART - 1) "](" t ")" substr(l, RSTART + RLENGTH)
      }
      Content = Content "\n" l
    }
  }
  handleTitle(0, 2)
}

function linkify(t) { t = tolower(t); gsub(/ /, "-", t); gsub(/[^-a-z0-9_]/, "", t); return t }
function fname(s) { gsub(/ /, "_", s); return s }
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
