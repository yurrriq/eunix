prefix ?= $(error Must set prefix)
CFLAGS ?= -Wall -Werror -std=c99
cpif   ?= | cpif
NW_SRC := $(wildcard src/*.nw)
C_SRC  := ${NW_SRC:.nw=.c}
RS_SRC := $(patsubst src/%.nw,src/bin/%.rs,$(filter-out src/whoami.nw,${NW_SRC}))
SRC    := ${C_SRC} ${RS_SRC}
PDF    := $(patsubst src/%.nw,docs/%.pdf,${NW_SRC})
BIN    := $(patsubst src/%.c,bin/%,${C_SRC}) $(patsubst src/bin/%.rs,bin/%-rs,${RS_SRC})

ifneq (,$(findstring B,$(MAKEFLAGS)))
latexmk_flags = -gg
endif

latexmk_flags += -cd -pdf

.PHONY: all check clean

.SUFFIXES:
.SUFFIXES: .c .nw

.nw.c:
	notangle -R'$@' $< ${cpif} $@

src/bin/%.rs: src/%.nw
	notangle -R'$@' $< ${cpif} $@

src/%.pdf: src/%.tex $(wildcard src/*.tex) src/%.c src/bin/%.rs
	latexmk ${latexmk_flags} $<

src: ${SRC}

bin: ${BIN}

doc: ${PDF}

install: bin doc
	install -dm755 ${prefix}/bin
	install -m755 -t ${prefix}/bin ${BIN}
	install -dm755 ${prefix}/docs
	install -m755 -t ${prefix}/docs ${PDF}

check: eunix.bats bin
	@ bats $^


clean:
	$(foreach pdf,${PDF},latexmk ${latexmk_flags} -f -C ${pdf};)
	rm -fR ${BIN} ${C_SRC}{~,} src/_minted-*

src/%.tex: src/%.nw
	noweave -n -delay -index $< ${cpif} $@

bin/%: src/%.c
	${CC} ${CFLAGS} -o $@ $<

bin/%-rs: src/bin/%.rs
	@ cargo install --bin $*-rs --force --path $(PWD) --root $(PWD)

docs/%.pdf: src/%.pdf
	install -dm755 $(@D)
	install -m644 $< $@
