
@goal pg @params A B
  echo "pg body: $A $B"

@goal c
# making sure calls twice
@calls pg @args 'a_val' 'b_val'
@calls pg @args 'a_val' 'b_val'