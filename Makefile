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

figures/overunderindexing.png: best_new_music.R derived_data/pitchfork_clean.csv
	Rscript best_new_music.R

figures/score_dist_by_genre.png: best_new_music.R derived_data/pitchfork_clean.csv
	Rscript best_new_music.R

figures/contrarian_index.png: contrarian_index.R derived_data/pitchfork_clean.csv source_data/riaaAlbumCerts_1999-2019.csv
	Rscript contrarian_index.R

figures/contrarian_index_bar.png: contrarian_index.R derived_data/pitchfork_clean.csv source_data/riaaAlbumCerts_1999-2019.csv
	Rscript contrarian_index.R

figures/word_distribution_plot.png: article_word_processing.R derived_data/pitchfork_clean.csv
	Rscript article_word_processing.R

figures/wordcloud.png: article_word_processing.R derived_data/pitchfork_clean.csv
	Rscript article_word_processing.R

report.pdf: tmp/tinytex_installed report.tex best_new_music.R contrarian_index.R aritcle_word_processing.R figures/contrarian_index.png figures/score_distribution.png figures/overunderindexing.png figures/score_dist_by_genre.png figures/contrarian_index_bar.png figures/word_distribution_plot.png figures/wordcloud.png
	R -e "tinytex::pdflatex(\"report.tex\")"
	pdflatex report.tex	

tmp/tinytex_installed:
	rm -f tmp/tinytex_installed
	Rscript install_tinytex.R
	touch tmp/tinytex_installed 
