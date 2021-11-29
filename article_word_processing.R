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
webshot::install_phantomjs()

pitchfork = read.csv("derived_data/pitchfork_clean.csv", header = TRUE)
pitchfork_bad = as_tibble(pitchfork) %>% filter(score <= 4.7)
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
  labs(title = "Most Frequenct Words: Good Reviews Removing Common Music Words", x = "Frequency", y ="Word") +
  theme_bw()

freq_plot1 <- ggplot(data = word_freq_nostop[1:20,], aes(x = frequency, y = reorder(word, frequency))) +
  geom_bar(stat = "identity", fill = "firebrick") +
  labs(title = "Most Frequenct Words: Good Reviews", x = "Frequency", y ="Word") +
  theme_bw()

freq_plot3 <- ggplot(data = word_freq_bad[1:20,], aes(x = frequency, y = reorder(word, frequency))) +
  geom_bar(stat = "identity", fill = "slateblue") +
  labs(title = "Most Frequenct Words: Bad Reviews", x = "Frequency", y ="Word") +
  theme_bw()

freq_plot <- plot_grid(freq_plot1, freq_plot2, freq_plot3, ncol=3)
freq_plot

word_cloud2 <- wordcloud2(data=word_freq)
word_cloud2

word_cloud_bad <- wordcloud2(data=word_freq_bad)
word_cloud_bad

saveWidget(word_cloud2,"figures/wordcloud.html",selfcontained = F)
webshot::webshot("figures/wordcloud.html","figures/wordcloud.png",vwidth = 1992, vheight = 1744, delay =10)

saveWidget(word_cloud_bad,"figures/wordcloud_bad.html",selfcontained = F)
webshot::webshot("figures/wordcloud_bad.html","figures/wordcloud_bad.png",vwidth = 1992, vheight = 1744, delay =10)

if (!dir.exists("figures")){
  dir.create("figures")
  ggsave("figures/word_distribution_plot.png", 
         width = 15, height = 5, 
         plot = freq_plot)
} else {
  ggsave("figures/word_distribution_plot.png", 
         width = 12, height = 5, 
         plot = freq_plot)
}

# colfunc <- colorRampPalette(c("black", "red"))
# color_pal <- colfunc(50)
# 
# word_cloud <- wordcloud(terms_vec, term_frequency, 
#                         max.words = 50, colors = color_pal)
