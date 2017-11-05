CFLAGS ?= -Wall -std=c99
cpif   ?= | cpif
NW_SRC := $(wildcard src/*.nw)
C_SRC  := ${NW_SRC:.nw=.c}
PDF    := $(patsubst src/%.nw,docs/%.pdf,${NW_SRC})
BIN    := $(patsubst src/%.c,bin/%,${C_SRC})


ifneq (,$(findstring B,$(MAKEFLAGS)))
latexmk_flags = -gg
endif

latexmk_flags += -cd -pdf


.SUFFIXES: .nw .c .tex .pdf

.nw.c:
	notangle $< ${cpif} $@
	indent -kr -nut $@

.tex.pdf:
	latexmk ${latexmk_flags} $<


.PHONY: all
all: ${C_SRC} ${BIN} ${PDF}


.PHONY: clean
clean:
	$(foreach pdf,${PDF},latexmk ${latexmk_flags} -f -C ${pdf};)
	rm -fR ${BIN} ${C_SRC}{~,} docs/_minted-*


docs/%.tex: src/%.nw
	noweave -autodefs c -n -delay -index $< ${cpif} $@


bin/%: src/%.c
	@ mkdir -p $(dir $@)
	${CC} ${CFLAGS} -o $@ $<
