library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)

pitchfork <- read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork <- as_tibble(pitchfork)

top_albums <- read.csv("source_data/riaaAlbumCerts_1999-2019.csv", header = TRUE)
top_albums <- as_tibble(top_albums) %>% mutate(Status_standard = sub('.* ', '', Status))


simplify_strings <- function(s){
  s <- str_to_lower(s);
  s <- str_trim(s);
  s <- str_replace_all(s,"[^a-z]+"," ")
  s <- str_replace_all(s," ","")
  s
}

pitchfork <- pitchfork %>% mutate(key = paste0(simplify_strings(album),";",simplify_strings(artist))) 
top_albums <- top_albums %>% mutate(key = paste0(simplify_strings(Album),";",simplify_strings(Artist)))

pitchfork_avg_scores <- pitchfork %>% group_by(release_year) %>%
  summarize(avg_score_pitchfork = mean(score), pitchfork_albums_reviewed = n())

avg_top_album_scores <- top_albums %>% 
#  filter(Status_standard == "Platinum") %>%
  inner_join(pitchfork, by = "key") %>% 
  group_by(release_year) %>% 
  summarize(avg_score_top_album = mean(score), albums_reviewed = n()) %>%
  inner_join(pitchfork_avg_scores, by = "release_year") %>%
  filter(release_year >= 1999) %>%
  mutate(favorable = ifelse(avg_score_pitchfork - avg_score_top_album > 0, "Unfavorable", "Favorable"))

contrarian_index <- ggplot(avg_top_album_scores, aes(x = release_year, y = avg_score_top_album, group = 1)) +
  geom_line(size = 1) +
  geom_point(size = 2) + 
  geom_line(aes(x = release_year, y = avg_score_pitchfork, color = "red"), size = 1) +
  geom_point(aes(x = release_year, y = avg_score_pitchfork, color = "red")) +
#  geom_ribbon(data = avg_top_album_scores[avg_top_album_scores$avg_score_top_album >= avg_top_album_scores$avg_score_pitchfork,], 
#              aes(x = release_year, ymin=avg_score_top_album, ymax=avg_score_pitchfork), fill = "red", alpha=0.5) +
  xlim(1998, 2020) +
  labs(title = "Pitchfork Average Score Assigned to Popular Albums vs. All Albums", 
       x = "Release Year", y ="Average Score") 
  


top_albums %>% 
  inner_join(pitchfork, by = "key") %>% 
  filter(release_year == 2000) %>%
  select(artist, album, score, release_year)



  
  
contrarian_index2 <- ggplot(avg_top_album_scores, aes(x=avg_score_pitchfork, xend=avg_score_top_album, 
                                 y=release_year, yend=release_year, color=favorable)) +
  theme_bw() +
  geom_segment(size = 6) + 
  scale_color_manual(values = c('seagreen', 'firebrick')) +
  labs(title = "Difference Between Average Pitchfork Scores and Pitchfork Scores of Popular Albums", 
       x = "Difference Between Average Score on All Albums and Average Score of Popular Albums ", y ="Average Score") +
  geom_label(aes(label=round(avg_score_pitchfork,2), 
                 x=ifelse(favorable == "Favorable", avg_score_pitchfork - .1, avg_score_pitchfork + .1)), 
             size = 4) +
  geom_label(aes(label=round(avg_score_top_album,2), 
                 x=ifelse(favorable == "Favorable", avg_score_top_album + .1, avg_score_top_album - .1)), 
                 size=4) + 
  scale_y_continuous(breaks = seq(1999, 2018, by = 1),1)
  
if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/contrarian_index.png", 
         width = 5, height = 5, 
         plot = contrarian_index)
} else {
  ggsave("figures/contrarian_index.png", 
         width = 5, height = 5, 
         plot = contrarian_index)
}

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/contrarian_index_bar.png", 
         width = 10, height = 5, 
         plot = contrarian_index2)
} else {
  ggsave("figures/contrarian_index_bar.png", 
         width = 10, height = 5, 
         plot = contrarian_index2)
}
  