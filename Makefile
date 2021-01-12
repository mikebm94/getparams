PREFIX ?= /usr/local
BINPREFIX ?= ${PREFIX}/bin

all:
	@echo "There's nothing to build. Use 'make install'."

test:
	bats -r .

install:
	install -Dm755 bin/getparams "${DESTDIR}${BINPREFIX}/getparams"

uninstall:
	rm "${DESTDIR}${BINPREFIX}/getparams"

.PHONY: all test install uninstall
