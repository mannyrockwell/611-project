.PHONY: clean
.PHONY: shiny_app
SHELL: /bin/bash

clean:
	rm -rf derived_data/*
	rm -rf figures/*
	rm -rf report.pdf

derived_data/pitchfork_clean.csv: source_data/pitchfork.csv
	Rscript clean_data.R

derived_data/best_new_music.csv: best_new_music.R source_data/pitchfork_clean.csv
	Rscript best_new_music.R

figures/score_distribution.png: best_new_music.R derived_data/pitchfork_clean.csv
	Rscript best_new_music.R

figures/contrarian_index.png: contrarian_index.R derived_data/pitchfork_clean.csv source_data/riaaAlbumCerts_1999-2019.csv
	Rscript contrarian_index.R

report.pdf: report.tex figures/contrarian_index.png figures/score_distribution.png 
	pdflatex report.tex

report.pdf: /tmp/tinytex_installed
	R -e "tinytex::pdflatex(\"report.tex\")

tmp/tinytex_installed:
	rm -f /tmp/tinytex_installed
	Rscript install_tinytex.R
	touch /tmp/tinytex_installed 
