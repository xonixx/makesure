
@goal a
@doc doc for a

@goal b
@depends_on a
@doc doc for b

@goal @glob 13_doc.tush
@depends_on a b
@doc doc for glob