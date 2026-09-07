PAPERS = $(patsubst %.md, %.pdf, $(wildcard *.md))
BIBTEX = $(wildcard *.bib)

all: $(PAPERS)

%.pdf: %.md $(BIBTEX)
	pandoc --citeproc --pdf-engine xelatex --bibliography $(BIBTEX) -f markdown $< -o $@

ASPELL_FLAGS = --lang=en --encoding=utf-8 --mode=markdown --add-extra-dicts=./.aspell.en.pws

# Interactive spell check
.PHONY: spell
spell:
	aspell $(ASPELL_FLAGS) check paper.md

# Non-interactive: print unknown words (useful for CI)
.PHONY: spell-list
spell-list:
	@aspell $(ASPELL_FLAGS) list < paper.md | sort -u

.PHONY: clean
clean:
	rm *.pdf
