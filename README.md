# ArgParser: command-line parsing for Oberon-2

The software in this repo is developed with the aid of AI.

`ArgParser.Mod` parses command-line options and commands for Oberon-2
programs built with voc (Vishap Oberon): long and short options,
clustered short options, integer and string option values, `--` to
end options, and usage messages.

A parser's `Usage` prints on standard output, for a program's `--help`.
A mistake on the command line, such as an unknown option or a missing
argument, prints an error and the usage on standard error, and exits
with status 2 (`UsageErrorStatus`).

`Simple.Mod`, `Commands.Mod` and `OneName.Mod` are example programs,
and the fixtures in `tests/` test ArgParser through them.

It moved here, with its history, from
[`oberon-tools`](https://github.com/tkurtbond/oberon-tools).

## Building, testing and installing

```sh
make                 # build the example programs with voc
make test            # build, then run the fixtures in tests/
make install         # copy ArgParser.Mod and Err.Mod to OBERON_MODULES
make uninstall       # remove them from OBERON_MODULES
make -f pocGNUmakefile test-poc   # build and test with poc instead
```

Other repos don't keep a copy of `ArgParser.Mod`. Their makefiles find
it through `vpath` in `OBERON_MODULES`, a colon-separated list of
directories, and voc builds it into their own build directories.
`make install` copies it to the first directory in `OBERON_MODULES`
(default `/usr/local/sw/versions/oberon/include`).

`make install` also installs `Err.Mod`, which writes text to standard
error with the interface of `Out` (`String`, `Char` and `Ln`). poc has
no `Platform.Write`, so there is a poc version too, `poc-rtl/Err.Mod`;
`make install` copies it to the `poc` subdirectory of that directory,
for other repos' poc builds to put on poc's import path.
