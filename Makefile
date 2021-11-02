.PHONY: clean
.PHONY: shiny_app
SHELL: /bin/bash

#This clean action removes any existing datasets, figures or reports generated in this Makefile
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