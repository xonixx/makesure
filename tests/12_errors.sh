
@reached_if true
@depends_on g1
@doc Doc in prelude
@options unsupported
@options
@shell unsupported
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
