.POSIX:
PREFIX ?= /usr/local
BINPREFIX ?= ${PREFIX}/bin

all:
	@echo "Run 'make install' to install getparams."

test: tools/bats-core/bin/bats
	@tools/bats-core/bin/bats -r test/

tools/bats-core/bin/bats:
	@git submodule update --init --recursive -- tools/bats-core

install:
	@install -Dm755 bin/getparams "${DESTDIR}${BINPREFIX}/getparams"

uninstall:
	@rm "${DESTDIR}${BINPREFIX}/getparams"

.PHONY: all test install uninstall
