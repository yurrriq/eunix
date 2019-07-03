CFLAGS ?= -Wall -std=c99
cpif   ?= | cpif
NW_SRC := $(wildcard src/*.nw)
C_SRC  := ${NW_SRC:.nw=.c}
PDF    := $(patsubst src/%.nw,docs/%.pdf,${NW_SRC})
BIN    := $(patsubst src/%.c,bin/%,${C_SRC})

prefix ?= docs


ifneq (,$(findstring B,$(MAKEFLAGS)))
latexmk_flags = -gg
endif

latexmk_flags += -cd -pdf


.PHONY: all check clean


%.c: %.nw
	notangle $< ${cpif} $@
	indent -kr -nut $@


src/%.pdf: src/%.tex src/%.c
	latexmk ${latexmk_flags} $<


all: ${C_SRC}


install: ${BIN} ${PDF}


check:
	@ bin/check


clean:
	$(foreach pdf,${PDF},latexmk ${latexmk_flags} -f -C ${pdf};)
	rm -fR ${BIN} ${C_SRC}{~,} docs/_minted-*


src/%.tex: src/%.nw
	noweave -autodefs c -n -delay -index $< ${cpif} $@


bin/%: src/%.c
	@ mkdir -p $(dir $@)
	${CC} ${CFLAGS} -o $@ $<

${prefix}/%.pdf: src/%.pdf
	install -m644 $< $@

nix/nixpkgs.json:
	@ nix-prefetch-github NixOS nixpkgs --rev master >$@
