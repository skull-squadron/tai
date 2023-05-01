SOURCES = $(shell find src lib -type f -name '*.cr')
SPECS = $(shell find spec -type f -name '*.cr')

CRYSTAL ?= crystal
SHARDS ?= shards
WATCHMAN_MAKE ?= watchman-make

CRYSTALFLAGS ?=
CRYSTALSPECFLAGS ?=
CRYSTALBUILDFLAGS ?=
WATCHFLAGS ?= -p 'lib/**/*.cr' 'src/**/*.cr' 'spec/**/*.cr' GNUmakefile -t test


test: spec

spec: $(SPECS) $(SOURCES)
	$(CRYSTAL) spec $(CRYSTALFLAGS) $(CRYSTALSPECFLAGS)

watch: watchman
watchman:
	$(WATCHMAN_MAKE) $(WATCHFLAGS)
