## Files

- [makesure.awk](../makesure.awk) 
  - **what:** the core of the tool implemented in AWK
- [makesure_dev](../makesure_dev) 
  - **what:** sh-wrapper over `makesure.awk`. Relatively immutable. 
  - **why:** used in running tests, has some configurability for this purpose
- [makesure_candidate](../makesure_candidate)
  - **what:** self-contained sh script, that embeds the `makesure.awk` content as AWK CLI argument
  - **why** the final tool requires some sh additions to correctly initialize the core. Serves a candidate for next release. Need this as separate entity to be able to test the compiled version of a tool.
  - **how** is generated via `./makesure candidate` from `makesure.awk`.
- [makesure](../makesure)
  - **what** contains a latest released version of a tool
  - **why** this one should be very stable and only change with a new release published. Serves the source of `./makesure --self-update`. *Should only change when the `makesure` version is incremented!*
  - **how** copied from `makesure_candidate` at the time of release in `./makesure release`.