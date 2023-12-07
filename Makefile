prefix ?= $(error Must set prefix)
CFLAGS ?= -Wall -Werror -std=c99
cpif   ?= | cpif
NW_SRC := $(wildcard src/*.nw)
C_SRC  := ${NW_SRC:.nw=.c}
PDF    := $(patsubst src/%.nw,docs/%.pdf,${NW_SRC})
BIN    := $(patsubst src/%.c,bin/%,${C_SRC})


ifneq (,$(findstring B,$(MAKEFLAGS)))
latexmk_flags = -gg
endif

latexmk_flags += -cd -pdf


.PHONY: all check clean


%.c: %.nw
	notangle $< ${cpif} $@


src/%.pdf: src/%.tex src/%.c
	latexmk ${latexmk_flags} $<


src: ${C_SRC}

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
	noweave -autodefs c -n -delay -index $< ${cpif} $@


bin/%: src/%.c
	${CC} ${CFLAGS} -o $@ $<

docs/%.pdf: src/%.pdf
	install -dm755 $(@D)
	install -m644 $< $@
