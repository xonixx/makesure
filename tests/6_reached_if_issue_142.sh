
@define ISSUE_142 'a     b' # 5 spaces

@goal g
@reached_if echo "$ISSUE_142"
echo 'Should not show this'

@goal g1
@reached_if echo "a     b"
echo 'Should not show this'

@goal g2
  @reached_if echo "a     b"
echo 'Should not show this'


