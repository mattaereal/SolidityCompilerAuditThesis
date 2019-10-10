#!/bin/bash

pdflatex thesis.tex -o thesis.pdf
mv *.log *.run.xml *.bcf *.toc *.blg *.bbl *.fdb_latexmk *.fls *.aux build
