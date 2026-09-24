# AGENTS.md

Working notes for an agent in this repo, which holds `ArgParser.Mod`,
an Oberon-2 command-line parser built with voc (Vishap Oberon), and
its example programs `Simple.Mod`, `Commands.Mod` and `OneName.Mod`.
It moved here, with its history, from `~/Repos/Oberon/oberon-tools`.

## Build / test / install

```sh
make                 # the example programs, with voc
make test            # build, then run tests/*.test; ends "N ok, M failed"
make install         # copy ArgParser.Mod to the first directory in OBERON_MODULES
make uninstall       # remove it from there
make -f pocGNUmakefile test-poc   # build and test with poc instead
tests/run-tests.sh -o cmd-add cluster-repeat   # selected fixtures, with their real output
```

- The `GNUmakefile` builds a library module with `voc -f -s` and a
  program with `voc -f -m`. A new program goes in `PROGRAMS` and in
  `.gitignore`.
- **Other repos don't keep a copy of `ArgParser.Mod`.** Their makefiles
  find it through `vpath` in `OBERON_MODULES`, a colon-separated list
  of directories (default `/usr/local/sw/versions/oberon/include`),
  and voc builds it into their own build directories. Its users are
  `~/Repos/Oberon/oberon-tools` and `~/Repos/Oberon/Ropes`.
- **After changing `ArgParser.Mod`, run `make test`, then
  `make install`**, then rebuild and test the repos that use it.
  `make install` compiles `ArgParser.Mod` first, so a module that
  doesn't compile is never installed.
- **`make uninstall` removes only `ArgParser.Mod`** from the first
  directory in `OBERON_MODULES`, and succeeds if it is already gone.
  Until you install it again, the repos that use it stop with
  "ArgParser.Mod is not in OBERON_MODULES".
- `pocGNUmakefile` builds the programs with poc into `poc-build/`. See
  its header for why the build goes there. poc has no `Args` module,
  so `poc-rtl/Args.Mod` is a shim over poc's `Modules`.
- **Fixtures**: `tests/NAME.test` has the lines `program`, `arg`
  (repeatable; a bare `arg` is an empty argument), optional `env`,
  `dir` and `input`, then `status`, and `output` followed by the
  expected text. Standard output and standard error are compared
  mixed together. The harness ignores trailing white space and voc's
  `Terminated by Halt(N).` lines.
- **Regenerate fixtures from real runs; never hand-edit one that
  embeds generated text.** 31 fixtures embed a program's usage text
  (help, and most errors, print it), so a change to `Usage` or to an
  example program's options means regenerating all of them.
- **Build fixture argument lists in Python (`subprocess` with a list),
  not with a shell `eval`**, which collapses spaces inside quoted
  arguments.
- An argument or option value longer than `MaxStringLength` (4095)
  characters is cut short without an error.
