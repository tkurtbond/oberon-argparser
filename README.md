# ArgParser: command-line parsing for Oberon-2

`ArgParser.Mod` parses command-line options and commands for Oberon-2
programs built with voc (Vishap Oberon): long and short options,
clustered short options, integer and string option values, `--` to
end options, and usage messages.

`Simple.Mod`, `Commands.Mod` and `OneName.Mod` are example programs,
and the fixtures in `tests/` test ArgParser through them.

It moved here, with its history, from
[`oberon-tools`](https://github.com/tkurtbond/oberon-tools).

## Building, testing and installing

```sh
make                 # build the example programs with voc
make test            # build, then run the fixtures in tests/
make install         # copy ArgParser.Mod to OBERON_MODULES
make uninstall       # remove it from OBERON_MODULES
make -f pocGNUmakefile test-poc   # build and test with poc instead
```

Other repos don't keep a copy of `ArgParser.Mod`. Their makefiles find
it through `vpath` in `OBERON_MODULES`, a colon-separated list of
directories, and voc builds it into their own build directories.
`make install` copies it to the first directory in `OBERON_MODULES`
(default `/usr/local/sw/versions/oberon/include`).
