# AGENTS.md

Working notes for an agent in this repo, which holds `ArgParser.Mod`,
an Oberon-2 command-line parser built with voc (Vishap Oberon), and
its example programs `Simple.Mod`, `Commands.Mod`, `OneName.Mod` and
`Folded.Mod` (a parser with a `filter`, which opp uses on VAX/VMS to
lowercase options).
It moved here, with its history, from `~/Repos/Oberon/oberon-tools`.
It also holds `Err.Mod`, text output to standard error, which moved
here from oberon-tools so that it is installed with `ArgParser.Mod`.

## Build / test / install

```sh
make                 # the example programs, with voc
make test            # build, then run tests/*.test; ends "N ok, M failed"
make install         # copy ArgParser.Mod and Err.Mod to the first directory in VOC_OBERON_MODULES
make uninstall       # remove them from there
make -f pocGNUmakefile test-poc   # build and test with poc instead
make -f pocGNUmakefile install    # build the poc library argparser (-O2 and -OC) into POC_OBERON_LIBRARIES/argparser
tests/run-tests.sh -o cmd-add cluster-repeat   # selected fixtures, with their real output
make distcheck       # write the release tarball in dist/, then build and test it unpacked
make dist-sign       # sign it (gpg, GPG_KEY for another key)
```

- The `GNUmakefile` builds a library module with `voc -f -s` and a
  program with `voc -f -m`. A new program goes in `PROGRAMS` and in
  `.gitignore`.
- **Other repos don't keep a copy of `ArgParser.Mod` or `Err.Mod`.**
  Their makefiles find them through `vpath` in `VOC_OBERON_MODULES`, a colon-separated list
  of directories (default `/usr/local/sw/versions/oberon/voc/include`),
  and voc builds it into their own build directories. Its users are
  `~/Repos/Oberon/oberon-tools` and `~/Repos/Oberon/Ropes`.
- **After changing `ArgParser.Mod` or `Err.Mod`, run `make test`,
  then `make install`**, then rebuild and test the repos that use
  them. `make install` compiles the voc modules first, so a module
  that doesn't compile is never installed.
- **`Err.Mod` is for voc builds only**: poc's runtime library,
  poc-rtl, has its own `Err` (and `Args`), with the same `String`,
  `Char` and `Ln`, unbuffered, and poc takes a library module before
  any source of that name.
- **`make uninstall` removes only what `make install` copied**:
  `ArgParser.Mod` and `Err.Mod` from the first directory in
  `VOC_OBERON_MODULES`. It succeeds if they are already gone. Until
  you install them again, the repos that use them stop with
  "ArgParser.Mod is not in VOC_OBERON_MODULES" (or `Err.Mod`).
- `pocGNUmakefile` builds the programs with the installed poc (`POC`
  for another) in `poc-build/`, where the sources are symlinked. See
  its header for why the build goes there. Its `install` builds the
  poc library `argparser`, for `-O2` and `-OC`, in `argparser/` under
  `POC_OBERON_LIBRARIES` (default `/usr/local/sw/versions/oberon/poc/lib`), where other repos' poc makefiles find it with
  `-library-path`, and `uninstall` removes what it wrote. poc refuses
  a library built by another poc version: install again after
  upgrading poc.
- **Fixtures**: `tests/NAME.test` has the lines `program`, `arg`
  (repeatable; a bare `arg` is an empty argument), optional `env`,
  `dir` and `input`, then `status`, and `output` followed by the
  expected text. Standard output and standard error are compared
  mixed together, so a fixture doesn't show which one a line went
  to; check that by running the program. The harness ignores
  trailing white space and voc's `Terminated by Halt(N).` lines.
- **`Usage` writes to standard output, and errors, with the usage
  after them, to standard error.** Every piece of usage and error
  text goes through the `WriteString`, `WriteChar` and `WriteLn`
  procedure variables, which `UseOut` points at `Out` and `UseErr`
  at `Err`. `UseErr` flushes `Out` first, so a program's earlier
  output still comes first. A mistake on the command line exits with
  `UsageErrorStatus` (2) through `Platform.Exit`, not `HALT`, which
  in voc writes `Terminated by Halt(N).`.
- **Regenerate fixtures from real runs; never hand-edit one that
  embeds generated text.** 31 fixtures embed a program's usage text
  (help, and most errors, print it), so a change to `Usage` or to an
  example program's options means regenerating all of them.
- **Build fixture argument lists in Python (`subprocess` with a list),
  not with a shell `eval`**, which collapses spaces inside quoted
  arguments.
- An argument or option value longer than `MaxStringLength` (4095)
  characters is cut short without an error.

## Making a release

`VERSION` in the `GNUmakefile` is the version, `x.y.z`; `NEWS.md` has a
section for each release, `## x.y.z (date)`, newest first, saying what
changed for a program that uses ArgParser. To release:

1. Set `VERSION`, and write its section in `NEWS.md` (`git log
   v<last>..`).
2. `make test` and `make -f pocGNUmakefile test-poc`; then `make
   install` and `make -f pocGNUmakefile install`, and rebuild and test
   the repos that use ArgParser (opp, oberon-tools, Ropes).
3. Commit ("ArgParser x.y.z") and push.
4. `make distcheck`, then `make dist-sign`. `make dist` refuses a working
   tree that differs from `HEAD`, a `NEWS.md` without the version's
   section, and a tag `vx.y.z` on another commit. Each run writes a new
   tarball, so sign and publish the one `distcheck` checked.
5. Tag, signed, and push the tag: `git tag -s vx.y.z -m "ArgParser
   x.y.z"`, `git tag -v vx.y.z`, `git push origin vx.y.z`.
6. Publish: `gh release create vx.y.z
   dist/oberon-argparser-x.y.z.tar.gz{,.sha256,.asc} --title "ArgParser
   x.y.z" --notes-file <notes>`, the notes being `NEWS.md`'s section and
   how to install (the README's "Building, testing and installing").

gpg asks for the key's passphrase for the tag and the signature; in a
terminal, with `GPG_TTY=$(tty)`.
