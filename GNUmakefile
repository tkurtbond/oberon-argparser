VOC=voc
VOCFLAGS=-f
VOCMAIN=-m

# make install copies the shared modules to the first directory in
# OBERON_MODULES (a colon-separated list), where other repos' makefiles
# find them.  Err, which writes to standard error, has a poc version too,
# in poc-rtl, since poc has no Platform.Write; it goes in the poc
# subdirectory, for other repos' poc builds to put on poc's import path.
OBERON_MODULES ?= /usr/local/sw/versions/oberon/include
INSTALLDIR = $(firstword $(subst :, ,$(OBERON_MODULES)))
MODULES = ArgParser.Mod Err.Mod
POC_MODULES = poc-rtl/Err.Mod
POC_INSTALLDIR = $(INSTALLDIR)/poc

PROGRAMS=Simple Commands OneName

.PHONY: all clean test test-verbose install uninstall

all: $(PROGRAMS) $(MODULES:.Mod=.o)

# All the example programs import ArgParser, so they need its symbol file
# (built along with ArgParser.o) and are rebuilt when it changes.
$(PROGRAMS): ArgParser.o

# ArgParser writes its errors to standard error with Err.
ArgParser.o: Err.o


%: %.Mod
	$(VOC) $(VOCFLAGS) $(VOCMAIN) $<

%.o : %.Mod
	$(VOC) $(VOCFLAGS) -s $<


# Run the fixtures in tests/ against the example programs and report how
# many passed and failed.  See tests/run-tests.sh for the fixture format.
test: all
	./tests/run-tests.sh

# Like test, but announces each test and its outcome as it goes.
test-verbose: all
	./tests/run-tests.sh -v

# Install only a module that compiles.  (The poc versions are compiled by
# make -f pocGNUmakefile, not here.)
install: $(MODULES:.Mod=.o)
	install -d $(INSTALLDIR) $(POC_INSTALLDIR)
	install -m 644 $(MODULES) $(INSTALLDIR)
	install -m 644 $(POC_MODULES) $(POC_INSTALLDIR)

# Remove what make install copied, and only that.  The poc subdirectory is
# removed only if nothing else is left in it.
uninstall:
	rm -f $(addprefix $(INSTALLDIR)/,$(MODULES))
	rm -f $(addprefix $(POC_INSTALLDIR)/,$(notdir $(POC_MODULES)))
	rmdir $(POC_INSTALLDIR) 2>/dev/null || true

clean:
	-rm -fv $(PROGRAMS) *.c *.h *.o *.sym
	-rm -rfv *.dSYM
