
@reached_if true
@depends_on g1
@doc Doc in prelude
@options usupported
@shell usupported

@goal
  echo Goal without name

@goal g1
@depends_on unknown

@goal g1
@reached_if false
@reached_if false
  echo Goal already defined

@goal g2
@shell sh
@define A=1

@goal g3
@doc doc1
@doc doc2
@options timing
@unknown_directive arg
