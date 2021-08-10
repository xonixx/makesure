
@reached_if true
@depend_on g1
@doc Doc in prelude
@options usupported
@shell usupported

@goal
  echo Goal without name

@goal g1
@depend_on unknown

@goal g1
@reached_if false
@reached_if false
  echo Goal already defined

@goal g2
@shell sh
@define A=1

@goal g3
@options timing
