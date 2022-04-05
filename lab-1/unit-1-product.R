
library (tidyverse)
library(tidytext)
library(wordcloud2)

opd_clean <- read_csv("/Volumes/GoogleDrive/My Drive/College of Ed/Data/opd_survey.csv") %>%
  select(Role, Resource, Q21) %>%
  rename(text = Q21) %>%
  slice(-1, -2) %>%
  filter(Role == "Teacher") %>%
  na.omit() %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words)

opd_counts <- count(opd_clean, word, sort = TRUE)

wordcloud2(opd_counts,
           color = ifelse(opd_counts[, 2] > 1000, 'black', 'gray'))




