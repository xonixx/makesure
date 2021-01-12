
## Plan

1.  [x] Each goal execution should not create shared variables - this can introduce unwanted intent to rely on imperative execution model
2.  prelude
    - [x] prelude runs exactly 1 time
    - [x] goal is to initialize variables
    - [x] use @define to export variable for goals
        - [x] reuse export for MVP
3.  [x] Goals topological sort
4.  [ ] (?) Profiles a-la maven
5.  [ ] Find a way to share functions
6.  [ ] Pre-check? Post-check?
7.  [x] make @shell configurable
8.  [x] `-p` flag to print generated bash script 
9.  [x] provide goals to run as argument
10. [x] `-l` flag to show all goals
11. [x] per-goal documentation
12. [x] Make makesure to use Makesurefile file by default 
13. [x] Agree on single standard way to run the scenario
14. [x] dependency validation - non-existent dep
15. [x] dependency validation - cycle
16. [x] @reached_if should run before dependencies
17. [ ] show actual dependency loop path
18. [x] mention each goal executed - now doesn't print if goal has empty body
19. [x] handle custom build file via `-f`
20. [x] `-v` flag to show version 
21. [x] `-d` flag to show resolved dependencies
22. [x] introduce test suite via tush
23. [x] `-t` flag for timing for goals execution
    - [x] is it possible to ms precision?
    - [x] measure each goal
24. [ ] `-h` flag for help
25. [ ] (?) `-F` to force build despite the reached_if
26. [x] `-x` to enable tracing in bash
27. [x] support `@options silent` mode and flag `-s`
28. [x] allow override @define-s
    - [x] `-D "var=val"` / `--define "var=val"`
29. [x] support @options directive
    - [x] @options tracing
    - [x] @options silent
    - [x] @options timing
30. [ ] find a way to enable tracing for the prelude - this correlates with "prelude runs exactly 1 time"

## Ideas proved not to work
 - Idea with stupid_flush (which just sends 65K spaces to shell pipe) is broken: 
    - we can't handle correctly the situation when bash fails for wrong command, and we keep sending to broken pipe   