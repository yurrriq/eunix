CFLAGS ?= -Wall -std=c99
cpif   ?= | cpif
SRC    := $(wildcard *.nw)
BIN    := ${SRC:.nw=.c}
PDF    := ${SRC:.nw=.pdf}


.SUFFIXES: .nw .c .pdf .tex

.nw.c:
	notangle $< ${cpif} $@
	indent -kr -nut $@

.nw.tex:
	noweave -autodefs c -n -delay -index $< ${cpif} $@

.tex.pdf:
	latexmk -gg -e '$$pdflatex = q/xelatex %O -shell-escape %S/;' -pdf $<


.PHONY: all
all: ${BIN} ${PDF}
