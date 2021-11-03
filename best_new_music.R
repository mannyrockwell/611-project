library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)
library(ggplot2)

pitchfork = read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)


best_new_music <- pitchfork %>% filter(bnm == 1)
length(best_new_music)

min(pitchfork$release_year, na.rm = TRUE)

histogram1 <- ggplot(pitchfork, aes(x = score)) + 
  geom_histogram(aes(y = ..density..), color="black", fill="white", binwidth = 0.1) + 
  geom_density(alpha=.2, fill="#FF6666") 
histogram1

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


pitchfork %>% filter(score <= 0.1) %>% select(artist, album, link)


lowest_scores <- pitchfork %>% group_by(release_year) %>% mutate(lowest_score = min(score)) %>% 
  filter(score == lowest_score) %>% filter(release_year >= 1995) %>% arrange(desc(release_year)) %>% select(artist, album, score, date, release_year, link)

lowest_scores <- pitchfork %>% group_by(year(date)) %>% mutate(lowest_score = min(score)) %>% 
  filter(score == lowest_score) %>% arrange(desc(date)) %>% select(artist, album, score, date, release_year, link)

print(lowest_scores, n=30)


if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/score_distribution.png", 
         width = 5, height = 5, 
         plot = histogram1)
} else {
  ggsave("figures/score_distribution.png", 
         width = 5, height = 5, 
         plot = histogram1)
}
