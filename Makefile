COVER=$(wildcard cover_*.tex)
CV=$(wildcard cv*.tex)

%.pdf:
	xelatex %.tex

cv: $(CV)
	$(foreach i, $^, xelatex -output-directory="pdfs/" $i;)

cover: $(COVER)
	$(foreach i,$^, xelatex -output-directory="pdfs/" $i;)

clean:
	rm -r pdfs/*.log pdfs/*.out  pdfs/*.aux
