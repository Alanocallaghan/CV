cv: AOC_cv.tex 
	xelatex AOC_cv.tex

cover: cover_letter.tex
	xelatex cover_letter.tex

clean:
	rm *.log *.out  *.aux
