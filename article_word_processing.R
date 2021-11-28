library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)
library(ggplot2)
library(qdap)
library(tm)
library(wordcloud)
library(plotrix)
library(ggthemes)
library(RWeka)

pitchfork = read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)

article_source <- pitchfork %>% select(review) %>% as.vector() %>% VectorSource() 
article_corpus <- VCorpus(article_source)

clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, c(stopwords("en"), "coffee", "mug"))
  return(corpus)
}

cleaned_corp <- clean_corpus(article_corpus)

article_dtm <- DocumentTermMatrix(cleaned_corp)

article_tdm <- TermDocumentMatrix(cleaned_corp)
article_m <- as.matrix(article_tdm)

dim(article_m)
