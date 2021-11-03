library(tidyverse)
library(stringr)
library(lubridate)
library(highcharter)
library(dplyr)

pitchfork <- read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork <- as_tibble(pitchfork)

top_albums <- read.csv("source_data/riaaAlbumCerts_1999-2019.csv", header = TRUE)
top_albums <- as_tibble(top_albums)

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
  inner_join(pitchfork, by = "key") %>% 
  group_by(release_year) %>% 
  summarize(avg_score_top_album = mean(score), albums_reviewed = n()) %>%
  inner_join(pitchfork_avg_scores, by = "release_year")

contrarian_index <- ggplot(avg_top_album_scores, aes(x = release_year, y = avg_score_top_album, group = 1)) +
  geom_line() +
  geom_line(aes(x = release_year, y = avg_score_pitchfork, color = "red")) +
#  geom_ribbon(data = avg_top_album_scores[avg_top_album_scores$avg_score_top_album >= avg_top_album_scores$avg_score_pitchfork,], 
#              aes(x = release_year, ymin=avg_score_top_album, ymax=avg_score_pitchfork), fill = "red", alpha=0.5) +
  xlim(1998, 2020)


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
  
  
  
  
  
  
  