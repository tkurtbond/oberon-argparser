VOC=voc
VOCFLAGS=-f
VOCMAIN=-m

# make install copies the shared modules to the first directory in
# VOC_OBERON_MODULES (a colon-separated list), where other repos' makefiles
# find them.  Err is for voc builds: poc has its own, in its runtime
# library.
VOC_OBERON_MODULES ?= /usr/local/sw/versions/oberon/voc/include/
INSTALLDIR = $(firstword $(subst :, ,$(VOC_OBERON_MODULES)))
MODULES = ArgParser.Mod Err.Mod

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

# Install only a module that compiles.
install: $(MODULES:.Mod=.o)
	install -d $(INSTALLDIR)
	install -m 644 $(MODULES) $(INSTALLDIR)

# Remove what make install copied, and only that.
uninstall:
	rm -f $(addprefix $(INSTALLDIR)/,$(MODULES))

clean:
	-rm -fv $(PROGRAMS) *.c *.h *.o *.sym
	-rm -rfv *.dSYM
