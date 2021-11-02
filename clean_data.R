library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)

pitchfork = read.csv("source_data/pitchfork.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)

pitchfork_clean <- pitchfork %>% 
  mutate(simplified_genre = word(genre,1,sep = ",")) %>%
  mutate(date = mdy(date)) %>% 
  mutate(after_aquisition = ifelse(date > "2015-10-13", 1, 0))


if (!dir.exists("derived_data")){
  dir.create("derived_data")
  write.csv(pitchfork_clean, "derived_data/pitchfork_clean.csv")
} else {
  write.csv(pitchfork_clean, "derived_data/pitchfork_clean.csv")
}





