PAPERS = $(patsubst %.md, %.pdf, $(wildcard *.md))
BIBTEX = $(wildcard *.bib)

all: $(PAPERS)

%.pdf: %.md $(BIBTEX)
	pandoc --citeproc --pdf-engine xelatex --bibliography $(BIBTEX) -f markdown $< -o $@

.PHONY: clean
clean:
	rm *.pdf
