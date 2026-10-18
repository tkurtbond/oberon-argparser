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

A parser's `filter`, if a program sets it, is given every argument
before it is parsed, to change it: on VAX/VMS, where DCL makes what is
not quoted capitals, a program lowercases its options. A command's
parser without a filter uses the one above it.

`Simple.Mod`, `Commands.Mod`, `OneName.Mod` and `Folded.Mod` are
example programs, and the fixtures in `tests/` test ArgParser through
them. `Folded.Mod` has a filter.

It moved here, with its history, from
[`oberon-tools`](https://github.com/tkurtbond/oberon-tools).

## Building, testing and installing

```sh
make                 # build the example programs with voc
make test            # build, then run the fixtures in tests/
make install         # copy ArgParser.Mod and Err.Mod to VOC_OBERON_MODULES
make uninstall       # remove them from VOC_OBERON_MODULES
make -f pocGNUmakefile test-poc   # build and test with poc instead
make -f pocGNUmakefile install    # build the poc library argparser into POC_OBERON_LIBRARIES
make distcheck       # write dist/oberon-argparser-VERSION.tar.gz and test it
```

Releases are on GitHub's releases page, each a tarball with its `.sha256`
and a signature, `.asc`; `NEWS.md` says what each one changed. Unpack
one and install it as above.

Other repos don't keep a copy of `ArgParser.Mod`. Their makefiles find
it through `vpath` in `VOC_OBERON_MODULES`, a colon-separated list of
directories, and voc builds it into their own build directories.
`make install` copies it to the first directory in `VOC_OBERON_MODULES`
(default `/usr/local/sw/versions/oberon/voc/include`).

`make install` also installs `Err.Mod`, which writes text to standard
error with the interface of `Out` (`String`, `Char` and `Ln`), for voc
builds. poc's runtime library has its own `Err` and `Args`, which poc
builds use instead.

For poc, `make -f pocGNUmakefile install` builds ArgParser into the poc
library `argparser`, for both size models (`-O2` and `-OC`), in
`argparser/` under `POC_OBERON_LIBRARIES` (default `/usr/local/sw/versions/oberon/poc/lib`). Other repos' poc builds pass that
directory to poc with `-library-path`, and link the compiled module
instead of compiling `ArgParser.Mod` again. A library records the poc
that built it, so install again after upgrading poc.
