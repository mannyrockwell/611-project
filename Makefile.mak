.PHONY: clean
.PHONY: shiny_app
SHELL: /bin/bash

#This clean action removes any existing datasets, figures or reports generated in this Makefile
clean:
	rm -f derived_data/*.csv
	rm -f figures/*.png
	rm -f report.pdf

derived_data/best_new_music.csv: best_new_music.R source_data/pitchfork.csv
	Rscript best_new_music.R