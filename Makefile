.POSIX:
PREFIX ?= /usr/local
BINPREFIX ?= ${PREFIX}/bin

all:
	@echo "Run 'make install' to install getparams."

lint:
	@LC_ALL=C.UTF-8 shellcheck -s bash ${LINTOPTS} bin/* test/*.bats

test: tools/bats-core/bin/bats tools/bats-support/load.bash tools/bats-assert/load.bash
	@tools/bats-core/bin/bats ${TESTOPTS} -r test/

tools/bats-core/bin/bats:
	@git submodule update --init --recursive -- tools/bats-core

tools/bats-support/load.bash:
	@git submodule update --init --recursive -- tools/bats-support

tools/bats-assert/load.bash:
	@git submodule update --init --recursive -- tools/bats-assert

install:
	@install -Dm755 bin/getparams "${DESTDIR}${BINPREFIX}/getparams"

uninstall:
	@rm "${DESTDIR}${BINPREFIX}/getparams"

.PHONY: all lint test install uninstall
