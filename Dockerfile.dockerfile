FROM rocker/verse
LABEL Emmanuel Rockwell <erockwell@unc.edu>
ARG pwd
RUN R -e "install.packages(c('tidyverse','plotly','data.table','gbm','caret',\
'e1071', 'gridExtra', 'reshape', 'plyr', 'shiny','stringr', 'lubridate', 'highcharter'))"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "rstudio:$pwd" | chpasswd
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