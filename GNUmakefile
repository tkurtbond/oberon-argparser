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

PROGRAMS=Simple Commands OneName Folded

# The version make dist releases; NEWS.md must have a section for it.
VERSION = 0.1.0
DISTNAME = oberon-argparser-$(VERSION)
DISTDIR = dist

.PHONY: all clean test test-verbose install uninstall dist distcheck dist-sign

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

# make dist writes $(DISTDIR)/$(DISTNAME).tar.gz, what git tracks at HEAD
# under $(DISTNAME)/, and its .sha256. It refuses a working tree that
# differs from HEAD, a NEWS.md without a section for VERSION, and a tag
# v$(VERSION) on another commit. Each run writes a new tarball (tar and
# gzip record times), so make one, check it, sign it and publish that one.
dist:
	@test -z "$$(git status --porcelain)" || \
	  { echo "dist: the working tree differs from HEAD" >&2; exit 1; }
	@grep -q '^## $(VERSION) ' NEWS.md || \
	  { echo "dist: NEWS.md has no section for $(VERSION)" >&2; exit 1; }
	@if t=$$(git rev-parse -q --verify 'refs/tags/v$(VERSION)^{commit}'); then \
	  test "$$t" = "$$(git rev-parse HEAD)" || \
	  { echo "dist: v$(VERSION) is a tag on another commit" >&2; exit 1; }; fi
	install -d $(DISTDIR)
	git archive --format=tar.gz --prefix=$(DISTNAME)/ -o $(DISTDIR)/$(DISTNAME).tar.gz HEAD
	cd $(DISTDIR) && sha256sum $(DISTNAME).tar.gz > $(DISTNAME).tar.gz.sha256
	@echo "dist: $(DISTDIR)/$(DISTNAME).tar.gz"

# make distcheck makes the tarball, then unpacks it in a new temporary
# directory and builds and tests it there with voc and with poc, so that
# a file git does not track, or a test that needs this tree, fails it.
distcheck: dist
	@d=$$(mktemp -d) && trap 'rm -rf "$$d"' EXIT && \
	  tar -xzf $(DISTDIR)/$(DISTNAME).tar.gz -C "$$d" && \
	  $(MAKE) -C "$$d/$(DISTNAME)" test && \
	  $(MAKE) -C "$$d/$(DISTNAME)" -f pocGNUmakefile test-poc && \
	  echo "distcheck: $(DISTNAME).tar.gz builds and passes its tests"

# make dist-sign writes the tarball's detached signature, .asc, with gpg's
# default key, or GPG_KEY's.
dist-sign:
	gpg --armor --detach-sign $(if $(GPG_KEY),--local-user $(GPG_KEY)) \
	  $(DISTDIR)/$(DISTNAME).tar.gz

clean:
	-rm -fv $(PROGRAMS) *.c *.h *.o *.sym
	-rm -rfv *.dSYM $(DISTDIR)
