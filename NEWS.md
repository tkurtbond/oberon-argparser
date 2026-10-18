# NEWS

What changed in each release of ArgParser, newest first.

## 0.1.0 (2026-10-18)

The first release. ArgParser parses the command line of an Oberon-2
program built with voc (Vishap Oberon) or poc (the Peaseblossom Oberon
Compiler):

- Long options (`--width 80`, `--width=80`) and short ones (`-w 80`,
  `-w80`), short options clustered (`-abc`), and `--` to end options; a
  bare `-` is an argument.
- Options with no value, with a string, or with an integer checked
  against a range (`MakeOption`, `MakeStringOption`, `MakeIntOption`),
  each with a handler.
- Commands, each with a parser of its own (`MakeCommand`, `AddCommand`).
- A parser's `filter`, given every argument before it is parsed, to
  change it: on VAX/VMS, where DCL makes what is not quoted capitals, a
  program lowercases its options. A command's parser without a filter
  uses the one above it.
- `Usage` prints the options and commands on standard output, for a
  program's `--help`. A mistake on the command line prints an error and
  the usage on standard error, and exits with status 2
  (`UsageErrorStatus`).
- Arguments and option values up to 4095 characters (`MaxStringLength`).
- `Err.Mod`, text output to standard error with `Out`'s interface, for
  voc builds; poc's runtime has its own.

`make install` installs `ArgParser.Mod` and `Err.Mod` for voc, and
`make -f pocGNUmakefile install` the poc library `argparser`. The example
programs `Simple`, `Commands`, `OneName` and `Folded`, and 80 fixtures
in `tests/`, show and test it.
