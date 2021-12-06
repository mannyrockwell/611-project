FROM rocker/verse
LABEL Emmanuel Rockwell <erockwell@unc.edu>
ARG pwd

RUN R -e "install.packages(c('tidyverse','plotly','data.table','gbm','caret',\
'e1071', 'gridExtra', 'reshape', 'dplyr', 'shiny','stringr', 'lubridate', 'highcharter',\
'grid', 'cowplot', 'ggplot2', 'qdap', 'tm', 'wordcloud', 'plotrix', 'ggthemes', 'RWeka',\
'wordcloud2', 'viridis', 'colorRamps', 'webshot', 'htmlwidgets', 'shinythemes'))"
RUN R -e "install.packages('tinytex'); if(!library(tinytex, logical.return=T)) quit(status=10); tinytex::install_tinytex(dir=\"/opt/tinytex\")"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN adduser rstudio sudo
RUN apt update -y && apt install -y\
        ne\
        sqlite3\
	texlive-base\
	texlive-binaries\
        texlive-latex-base\
	texlive-latex-recommended\
	texlive-pictures\
        texlive-latex-extra\
	python3-pip

RUN pip3 install jupyter jupyterlab
RUN pip3 install numpy pandas sklearn plotnine matplotlib pandasql bokeh pymatch \
scipy statsmodels seaborn