library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)
library(ggplot2)
library(grid)
library(cowplot)

pitchfork = read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork = as_tibble(pitchfork) %>% group_by(simplified_genre) %>% 
  mutate(label = paste0(simplified_genre, "\n", round(mean(score),2)))

pitchfork %>% select(score) %>% summarize(median(score)) 
pitchfork %>% select(score) %>% summarize(mean(score)) 


best_new_music <- pitchfork %>% filter(bnm == 1)
length(best_new_music)

min(pitchfork$release_year, na.rm = TRUE)

histogram1 <- ggplot(pitchfork, aes(x = score)) + 
  geom_histogram(aes(y = ..density..), color="black", fill="white", binwidth = 0.1) + 
  geom_density(alpha=.2, fill="#FF6666") +
  labs(title = "Pitchfork Score Distribution", x = "Score", y ="Frequency") +
  theme_bw()
histogram1

histogram2 <- ggplot(pitchfork, aes(x = score, 
                      fill = factor(ifelse((score =="7.9"|score == "7.1"),"Underindexed", "Other")))) + 
  geom_histogram(color="black", binwidth = 0.1) +
  scale_fill_manual(name = "score", values=c("grey80", "red")) +
  labs(title = "Pitchfork Score Distribution: Underindexed Scores", x = "Score", y ="Frequency") +
  theme_bw()
histogram2

histogram3 <- ggplot(pitchfork, aes(x = score, 
                                    fill = factor(ifelse((score =="8"|score == "7"), "Overindexed", "Other")))) + 
  geom_histogram(color="black", binwidth = 0.1) +
  scale_fill_manual(name = "score", values=c("grey80", "seagreen")) +
  labs(title = "Pitchfork Score Distribution: Overindexed Scores", x = "Score", y ="Frequency") +
  theme_bw()
histogram3

histogram4 <- plot_grid(histogram2, histogram3)
histogram4

pitchfork_grouped <- pitchfork %>% group_by(label) %>% summarize(score = mean(score))


histogram5 <- ggplot(pitchfork, aes(x = score)) + 
  geom_histogram(aes(y = ..density..), color = "black", fill="white", binwidth = 0.1) + 
  geom_vline(aes(xintercept = mean(score)),col='red', linetype = "dashed")+
  geom_vline(data = pitchfork_grouped, mapping =aes(xintercept = score),col='blue', linetype = "dashed") +
  facet_wrap(label ~ ., ncol = 5) +
  labs(title = "Pitchfork Score Distribution by Genre", x = "Score", y ="Frequency")
histogram5

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
         width = 10, height = 5, 
         plot = histogram1)
} else {
  ggsave("figures/score_distribution.png", 
         width = 10, height = 5, 
         plot = histogram1)
}

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/underoverindexing.png", 
         width = 20, height = 5, 
         plot = histogram4)
} else {
  ggsave("figures/underoverindexing.png", 
         width = 20, height = 5, 
         plot = histogram4)
}

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/score_dist_by_genre.png", 
         width = 10, height = 5, 
         plot = histogram5)
} else {
  ggsave("figures/score_dist_by_genre.png", 
         width = 10, height = 5, 
         plot = histogram5)
}
