CC   ?= cc
cpif ?= | cpif


tools := \
	echo


.SUFFIXES: .nw .c .pdf .tex

.nw.c:
	notangle $< ${cpif} $@
	indent -kr -nut $@

.nw.tex:
	noweave -autodefs c -n -delay -index $< ${cpif} $@

.tex.pdf:
	latexmk -gg -e '$$pdflatex = q/xelatex %O -shell-escape %S/;' -pdf $<


.PHONY: all
all: ${tools} ${tools:=.pdf}


%: %.c
	${CC} -o $@ $<
