library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)


pitchfork = read.csv("pitchfork.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)

pitchfork <- pitchfork %>% 
  mutate(simplified_genre = word(genre,1,sep = ",")) %>%
  mutate(date = mdy(date)) %>% 
  mutate(after_aquisition = ifelse(date > "2015-10-13", 1, 0))

best_new_music <- pitchfork %>% filter(bnm == 1)
length(best_new_music)

min(pitchfork$release_year, na.rm = TRUE)

hist <- ggplot(pitchfork, aes(x = score)) + 
  geom_histogram(aes(y = ..density..), color="black", fill="white", binwidth = 0.1) + 
  geom_density(alpha=.2, fill="#FF6666") 
hist

ggplot(pitchfork, aes(x = score, color = simplified_genre)) + 
  geom_histogram(fill="white", binwidth = 0.1)


ggplot(pitchfork, aes(x = score)) + 
  geom_histogram(color = "black", fill="white", binwidth = 0.1) + 
  geom_vline(aes(xintercept = mean(score)),col='red', linetype = "dashed")+
  facet_wrap(simplified_genre ~ ., ncol = 2)

hchart(density(pitchfork$score), type = "area", color = "#B71C1C", name = "Score")


hchart(pitchfork$score, type = "area", color = "#111111", name = "Score")

pitchfork_year <- function(inputyear){
  pitchfork %>% filter(release_year %in% inputyear[1]:inputyear[2])
}

pitchfork_year(c(2015,2019))





