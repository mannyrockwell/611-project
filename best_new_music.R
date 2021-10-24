library(tidyverse)


pitchfork = read.csv("pitchfork.csv", header = TRUE)
pitchfork = as_tibble(pitchfork)

best_new_music <- pitchfork %>% filter(bnm == 1)
length(best_new_music)