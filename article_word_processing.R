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
library(wordcloud)
library(wordcloud2)
library(viridis)
library(colorRamps)
library(webshot)
library(htmlwidgets)
library(cowplot)
webshot::install_phantomjs()

pitchfork = read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork_bad = as_tibble(pitchfork) %>% filter(score <= 5.0)
pitchfork = as_tibble(pitchfork) %>% filter(bnm == 1)

article_source <- pitchfork %>% select(review) %>% as.vector() %>% 
  iconv('utf-8', 'ascii', sub='') %>% VectorSource() 
article_corpus <- VCorpus(article_source)

article_source_bad <- pitchfork_bad %>% select(review) %>% as.vector() %>% 
  iconv('utf-8', 'ascii', sub='') %>% VectorSource() 
article_corpus_bad <- VCorpus(article_source_bad)

clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, c(stopwords("en"), 
                "like", "music", "album","songs","song","record",
                "albums","sounds","records","band","just","even","can","much",
                "sounds","get","though","something","one","two","with","another",
                "sound","almost","still","without","also","way","never","every",
                "less","seems","yet","will","first","feel","feels", "it200231s"))
  return(corpus)
}

clean_corpus_nostop <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, c(stopwords("en"), "it200231s"))
  return(corpus)
}

cleaned_corp <- clean_corpus(article_corpus)
cleaned_corp_bad <- clean_corpus(article_corpus_bad)
cleaned_corp_nostop <- clean_corpus_nostop(article_corpus)

article_tdm <- TermDocumentMatrix(cleaned_corp)
article_m <- as.matrix(article_tdm)
article_bad_tdm <- TermDocumentMatrix(cleaned_corp_bad)
article_bad_m <- as.matrix(article_bad_tdm)
article_tdm_nostop <- TermDocumentMatrix(cleaned_corp_nostop)
article_m_nostop <- as.matrix(article_tdm_nostop)

term_frequency <- rowSums(article_m) %>%  sort(decreasing = TRUE) %>% 
  as.data.frame()
word_freq <- cbind(words = rownames(term_frequency), term_frequency)
names(word_freq) <- c("word","frequency")

term_frequency_bad <- rowSums(article_bad_m) %>%  sort(decreasing = TRUE) %>% 
  as.data.frame()
word_freq_bad <- cbind(words = rownames(term_frequency_bad), term_frequency_bad)
names(word_freq_bad) <- c("word","frequency")

term_frequency_nostop <- rowSums(article_m_nostop) %>%  
  sort(decreasing = TRUE) %>% as.data.frame()
word_freq_nostop <- cbind(words = rownames(term_frequency_nostop), 
                          term_frequency_nostop)
names(word_freq_nostop) <- c("word","frequency")

freq_plot2 <- ggplot(data = word_freq[1:20,], aes(x = frequency, y = reorder(word, frequency))) +
  geom_bar(stat = "identity", fill = "seagreen") +
  labs(title = "Most Frequent Words Good Reviews\n Removing Common Music Words", x = "Frequency", y ="Word") +
  geom_text(aes(label = frequency), hjust = 1.1) +
  theme_bw()

freq_plot1 <- ggplot(data = word_freq_nostop[1:20,], aes(x = frequency, y = reorder(word, frequency))) +
  geom_bar(stat = "identity", fill = "slateblue") +
  labs(title = "Most Frequent Words: Good Reviews\n Only Removing Common Stop Words", x = "Frequency", y ="Word") +
  geom_text(aes(label = frequency), hjust = 1.1) +
  theme_bw()

freq_plot3 <- ggplot(data = word_freq_bad[1:20,], aes(x = frequency, y = reorder(word, frequency))) +
  geom_bar(stat = "identity", fill = "firebrick") +
  labs(title = "Most Frequent Words: Bad Reviews\n Removing Common Music Words", x = "Frequency", y ="Word") +
  geom_text(aes(label = frequency), hjust = 1.1) +
  theme_bw()

freq_plot <- plot_grid(freq_plot1, freq_plot2, freq_plot3, ncol=3)
freq_plot

top_x <- 20

word_freq_good_rank <- word_freq %>% mutate(rank = row_number(desc(frequency))) %>%
  mutate(position = -1) %>%  filter(rank <= top_x)
word_freq_bad_rank <- word_freq_bad %>% mutate(rank = row_number(desc(frequency))) %>%
  mutate(position = 1) %>%  filter(rank <= top_x)

line_data_good <- word_freq_good_rank %>% left_join(word_freq_bad_rank, by="word")
line_data_bad <- word_freq_bad_rank %>% left_join(word_freq_good_rank, by="word")

line_data <- rbind(line_data_good, line_data_bad) %>% filter(rank)distinct_at(vars(word)) %>%
  mutate(good_rank=replace_na(rank.x,top_x+1),
         bad_rank=replace_na(rank.y,top_x+1))

word_freq_ranks <- union_all(word_freq_good_rank, word_freq_bad_rank)

word_comparison <- ggplot(word_freq_ranks) +
  geom_rect(aes(xmin=position-0.5, xmax=position+0.5, ymin=rank-0.45, ymax=rank+0.45, fill=rank), show.legend = FALSE) +
  geom_label(aes(x=position, y=rank, label=word), color = "black") +
  geom_segment(data=line_data[0:20,],aes(x=-0.5,xend=0.5, y=good_rank, yend=bad_rank, color = rank.x), show.legend = FALSE, size =1) +
  scale_y_reverse(breaks = 1:top_x) +
  scale_x_continuous(breaks=c(-1,1), labels=c("Good","Bad")) +
  scale_color_viridis(name = 'distortion', option = "C", direction = 1) +
  scale_fill_viridis(name = 'distortion', option = "C", direction = 1) +
  labs(x="Quality of Album", y="Rank", title="How do Good Reviews Differ from Bad Reviews?");





word_cloud2 <- wordcloud2(data=word_freq)
word_cloud2

word_cloud_bad <- wordcloud2(data=word_freq_bad, size = 0.8)
word_cloud_bad

saveWidget(word_cloud2,"figures/wordcloud.html",selfcontained = F)
webshot::webshot("figures/wordcloud.html","figures/wordcloud.png",vwidth = 1700, vheight = 1300, delay =20)

saveWidget(word_cloud_bad,"figures/wordcloud_bad.html",selfcontained = F)
webshot::webshot("figures/wordcloud_bad.html","figures/wordcloud_bad.png",vwidth = 1700, vheight = 1300, delay =20)

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/word_distribution_plot.png", 
         width = 12, height = 7, 
         plot = freq_plot)
} else {
  ggsave("figures/word_distribution_plot.png", 
         width = 12, height = 7, 
         plot = freq_plot)
}

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/word_comparison.png", 
         width = 10, height = 7, 
         plot = word_comparison)
} else {
  ggsave("figures/word_comparison.png", 
         width = 10, height = 7, 
         plot = word_comparison)
}

# colfunc <- colorRampPalette(c("black", "red"))
# color_pal <- colfunc(50)
# 
# word_cloud <- wordcloud(terms_vec, term_frequency, 
#                         max.words = 50, colors = color_pal)
