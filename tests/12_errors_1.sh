#@goal g15 should not have anything after goal name
#@goal g16 # but comment is OK

#@goal g17 @glob '*.txt' should not have anything after glob pattern
#@goal g18 @glob '*.txt' # but comment is OK

#@goal @glob '*.txt' should not have anything after glob pattern
#@goal @glob '*.txt' should_not_have_anything_after_glob_pattern

@goal @glob '*.txt' # but comment is OK
#
#@goal @glob     # absent glob pattern
#@goal g19 @glob # absent glob pattern