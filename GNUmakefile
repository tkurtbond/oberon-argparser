VOC=voc
VOCFLAGS=-f
VOCMAIN=-m

# make install copies the shared modules to the first directory in
# OBERON_MODULES (a colon-separated list), where other repos' makefiles
# find them.
OBERON_MODULES ?= /usr/local/sw/versions/oberon/include
INSTALLDIR = $(firstword $(subst :, ,$(OBERON_MODULES)))
MODULES = ArgParser.Mod

PROGRAMS=Simple Commands OneName

.PHONY: all clean test test-verbose install

all: $(PROGRAMS)

# All the example programs import ArgParser, so they need its symbol file
# (built along with ArgParser.o) and are rebuilt when it changes.
$(PROGRAMS): ArgParser.o


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

# Install only a module that compiles.
install: $(MODULES:.Mod=.o)
	install -d $(INSTALLDIR)
	install -m 644 $(MODULES) $(INSTALLDIR)

clean:
	-rm -fv $(PROGRAMS) *.c *.h *.o *.sym
	-rm -rfv *.dSYM
