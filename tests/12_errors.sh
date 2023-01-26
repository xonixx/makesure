
echo 'code in prelude'
echo 'more code in prelude'

@reached_if true
@depends_on g1
@doc Doc in prelude
@options unsupported
@options
@shell unsupported
@shell
@use_lib lib1

@goal
  echo Goal without name

@goal g1
@depends_on unknown

@goal g1
@depends_on
@reached_if false
@reached_if false
  echo Goal already defined

@goal g2
@use_lib unknown
@shell sh
@define A=1
@lib lib2

@goal g3
@doc doc1
@doc doc2
@options timing
@unknown_directive arg
@use_lib lib1
@use_lib lib2

@goal g13
@use_lib unknown1

@goal g14
@depends_on unknown1

@lib lib2

@goal @private
  echo 'private goal without name'

@goal g15 should not have anything after goal name
@goal g16 # but comment is OK

@goal g17 @glob '*.txt' should not have anything after glob pattern
#@goal g18 @glob '*.txt' # but comment is OK

@goal @glob '*.txt' should not have anything after glob pattern
@goal @glob '*.txt' should_not_have_anything_after_glob_pattern
#@goal @glob '*.txt' # but comment is OK

