# Pitchfork Data Analysis

## What does this project contain?
This project primarily uses data obtained from [components.one](https://components.one/datasets/pitchfork-reviews-dataset). The data itself is a web scrape of all album reviews on Pitchfork.com between the dates of January 5, 1999 and January 11, 2019. This project also uses data from [Kaggle.com](https://www.kaggle.com/danield2255/data-on-songs-from-billboard-19992019) on the Recording Instustry Association of America (RIAA) album sales. 

The intention of this project was to better understand the meaning of the scores assigned to albums in Pitchfork reviews, discover which album qualities attract a higher score, track trends in Pitchfork scores before and after the 2015 Conde Nast acquisition, and perform some natural language processing procedures to identify commonly used words in good versus bad reviews and distill the essence of the typical Pitchfork review. 

## How to build the docker image:
First, clone or pull the most recent git repository using something similar to the code below:

```
git pull https://github.com/mannyrockwell/bios-611-project
```

Next, build the docker image by running thise code from the directory containing the cloned repository:

```
docker build . -t 611project
docker run -v $PWD:/home/rstudio -p 8787:8787 -e PASSWORD=pw -t 611project
```

## How to generate the report:
Open Rstudio through docker and run the following code in the Rstudio to generate the report. 

```
make report.pdf
```

Individual figures and files can also be compiles using similar syntax.

## Shiny app:

I also built a simple [Shiny app](https://emmanuelrockwell.shinyapps.io/pitchfork_app_611/) so users can easily interact with the dataset and explore how the distribution of Pitchfork scores has changed over time. 

