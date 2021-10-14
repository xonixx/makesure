
@goal no_space
@doc no_space
echo no_space

@goal 'name with spaces' # no single quote allowed between single quotes
@doc 'name with spaces' # no single quote allowed between single quotes
echo 'name with spaces' # no single quote allowed between single quotes

@goal $'name with \' quote' # $'strings' allow quote escaping
@doc $'name with \' quote' # $'strings' allow quote escaping
echo $'name with \' quote' # $'strings' allow quote escaping

@goal default
@depends_on no_space 'name with spaces' $'name with \' quote'