
@options silent

@goal nat_order_test @glob *.tush
@reached_if [[ $INDEX -ge 22 ]] # only check the correct order on first 22 tests
  echo "$ITEM"

@goal default
@depends_on