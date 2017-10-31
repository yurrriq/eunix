CC   ?= cc
cpif ?= | cpif


tools := \
	echo


.SUFFIXES: .nw .c .pdf .tex
.nw.c:    ; notangle $< ${cpif} $@
.nw.tex:  ; noweave -autodefs c -n -delay -index $< ${cpif} $@
.tex.pdf: ; latexmk -e '$$pdflatex = q/xelatex %O -shell-escape %S/;' -pdf $<


.PHONY: all
all: ${tools} ${tools:=.pdf}


%: %.c
	${CC} -o $@ $<
