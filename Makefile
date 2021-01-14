.POSIX:
PREFIX ?= /usr/local
BINPREFIX ?= ${PREFIX}/bin

all:
	@echo "Run 'make install' to install getparams."

test:
	@bats -r .

install:
	@install -Dm755 bin/getparams "${DESTDIR}${BINPREFIX}/getparams"

uninstall:
	@rm "${DESTDIR}${BINPREFIX}/getparams"

.PHONY: all test install uninstall
