FROM rocker/verse
LABEL Emmanuel Rockwell <erockwell@unc.edu>
ARG pwd

RUN R -e "install.packages(c('tidyverse','plotly','data.table','gbm','caret',\
'e1071', 'gridExtra', 'reshape', 'dplyr', 'shiny','stringr', 'lubridate', 'highcharter',\
'grid','cowplot','ggplot2','qdap','tm','wordcloud','plotrix','ggthemes','RWeka',\
'wordcloud2','viridis','colorRamps','webshot','htmlwidgets'))"
RUN Rscript -e "install.packages('tinytex'); tinytex::r_texmf()"

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