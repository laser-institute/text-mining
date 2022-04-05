# ___________________________
# Script name: Unit 2 Topic Modeling
# Purpose of script: Analysis
# Author: Shaun Kellogg
# Date Created: 03-20-2021
# ___________________________
# Notes:
# 
# 
# ___________________________


# 1. PREPARE ####

## Load Packages ####

library(newsanchor)
library(tidyverse)
library(tidytext)
library(topicmodels)
library(forcats)
library(stm)
library(LDAvis)



#2. WRANNGLE ####

ts_forum_data <- read_csv("unit-3/data/ts_forum_data.csv", 
    col_types = cols(course_id = col_character(),
                     forum_id = col_character(), 
                     discussion_id = col_character(), 
                     post_id = col_character()
                     )
    )

View(ts_forum_data)

glimpse(ts_forum_data)

unique(ts_forum_data$course_name)

## Tidy Text ####

forums_tidy <- ts_forum_data %>%
  unnest_tokens(output = word, 
                input = post_content) %>%
  anti_join(stop_words, by = "word") %>%
  count(post_id, word)

view(count(forums_tidy, word, sort = T))

n_distinct(forums_tidy$post_id)
n_distinct(ts_forum_data$post_id)

forums_dtm <- forums_tidy %>%
  cast_dtm(post_id, word, n)


forums_dtm

#3. EXPLORE ####







#4. MODEL ####

## Topic Models ####

forums_lda <- LDA(forums_dtm, 
                  k = 10, 
                  control = list(seed = 123))

forums_lda

forum_topics <- tidy(forums_lda, matrix = "beta")

forums_lda %>%
  tidy() %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 2, scales = "free") +
  scale_y_reordered()

forum_top_terms <- 
  forum_topics %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)


forum_top_terms %>%
  mutate(topic=as.factor(topic),
        term=reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 2, scales = "free") +
  coord_flip()

forum_top_terms %>%
  mutate(term=reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 2, scales = "free") +
  scale_y_reordered()


## Structural Topic Models ####

# forums_untidy <- ts_forum_data %>%
#   unnest_tokens(output = word, input = post_content, format =  "html") %>% 
#   nest(word) %>%
#   mutate(text = map(data, unlist), 
#          text = map_chr(text, paste, collapse = " ")) %>%
#   select(!data)
  



forums_untidy <- ts_forum_data %>%
  unnest_tokens(output = word, input = post_content) %>%
  group_by(course_id, forum_id, discussion_id, post_id) %>%
  summarise(text = str_c(word, collapse = " ")) %>%
  ungroup()

# see https://stackoverflow.com/questions/49118539/opposite-of-unnest-tokens-in-r

# https://stackoverflow.com/questions/46734501/opposite-of-unnest-tokens

forums_processed <- textProcessor(forums_untidy$text, 
                                  metadata = forums_untidy,
                                  stem = TRUE)

out <- prepDocuments(forums_processed$documents, 
                     forums_processed$vocab, 
                     forums_processed$meta)

set.seed(01234)
forums_stm_10 <- stm(documents = out$documents, 
                     vocab = out$vocab,
                     K = 10,
                     max.em.its = 75, 
                     data = out$meta,
                     init.type = "Spectral", 
                     verbose = FALSE)

plot(forums_stm_10)

findThoughts(forums_stm_10, 
             texts = forums_untidy$text,
             n = 10, 
             topics = 2)


forums_processed <- textProcessor(ts_forum_data$post_content, 
                                  metadata = ts_forum_data,
                                  stem = TRUE)

temp <- prepDocuments(forums_processed$documents, 
                     forums_processed$vocab, 
                     forums_processed$meta)

set.seed(01234)
forums_stm_10 <- stm(documents = out$documents, 
                 vocab = out$vocab,
                 K = 10,
                 max.em.its = 75, 
                 data = out$meta,
                 init.type = "Spectral", 
                 verbose = FALSE)

plot(forums_stm_10)

meta<-temp$meta
vocab<-temp$vocab
docs<-temp$documents

a <- stm(documents=docs, 
       vocab=vocab, 
       K=10,
       data=meta, 
       max.em.its=50)

plot(a)

z<-comments[-temp$docs.removed,]
length(z)

thoughts3 <- findThoughts(a,texts=z,topics=3, n=10,thresh=0.0)

comments <- ts_forum_data %>%
  select(post_content)

z<-comments[-temp$docs.removed,]
length(z)

thoughts3 <- findThoughts(a,texts=z,topics=3, n=10,thresh=0.0)

z <- comments[-temp$docs.removed,]
length(z)

thoughts3 <- findThoughts(a, 
                          texts = z, 
                          topics = 3, 
                          n = 10, 
                          thresh = 0.0)

findThoughts(forums_stm_10, 
             texts = forums_processed$documents,
             n = 5, 
             topics = 9)

### Choosing a Value for K ####

findingk <- searchK(out$documents, 
                    out$vocab, K = c(5:15),
                    data = meta, verbose=FALSE)

save(findingk, file = "unit-3/data/findingk.Rda")

findingk2 <- load("unit-3/data/findingk.Rda")

plot(findingk)

forums_stm_14 <- stm(documents = out$documents, 
                     vocab = out$vocab,
                     K = 14,
                     max.em.its = 75, 
                     data = out$meta,
                     init.type = "Spectral", 
                     verbose = FALSE)

plot(forums_stm_14)

findThoughts(forums_stm, 
             texts = forums_untidy$text,
             n = 10, 
             topics = 2)



toLDAvis(mod = forums_stm_14, docs = out$documents)


tsdi_forum_data <- read_csv("unit-3/data/tsdi_forum_data.csv", 
                          col_types = cols(course_id = col_character(),
                                           forum_id = col_character(), 
                                           discussion_id = col_character(), 
                                           post_id = col_character()
                          )
)

forums_untidy <- ts_forum_data %>%
  unnest_tokens(output = word, input = post_content) %>%
  group_by(course_id, forum_id, discussion_id, post_id) %>%
  summarise(text = str_c(word, collapse = " ")) %>%
  ungroup()


# -----------------------------------


temp<-textProcessor(ts_forum_data$post_content, 
                    metadata = ts_forum_data,  
                    lowercase=TRUE, 
                    removestopwords=TRUE, 
                    removenumbers=TRUE,  
                    removepunctuation=TRUE, 
                    stem=TRUE, 
                    wordLengths=c(3,Inf),  
                    sparselevel=1,  
                    verbose=TRUE, 
                    onlycharacter= FALSE, 
                    striphtml=TRUE, 
                    customstopwords=NULL)


out <- prepDocuments(processed$documents, processed$vocab, processed$meta)

meta<-temp$meta
vocab<-temp$vocab
docs<-temp$documents

a<-stm(documents=docs, 
       vocab=vocab, 
       K=10,
       data=meta, 
       max.em.its=25,
       verbose = FALSE)

z<-ts_forum_data$post_content[-temp$docs.removed]
length(z)

plot(a)
  
findingk <- searchK(docs, 
                    vocab, 
                    K = c(10:20),
                    data = meta, 
                    verbose=FALSE)

plot(findingk)


temp<-textProcessor(ts_forum_data$post_content, 
                    metadata = ts_forum_data,  
                    lowercase=TRUE, 
                    removestopwords=TRUE, 
                    removenumbers=TRUE,  
                    removepunctuation=TRUE, 
                    stem=TRUE, 
                    wordLengths=c(3,Inf),  
                    sparselevel=1,  
                    verbose=TRUE, 
                    onlycharacter= FALSE, 
                    striphtml=TRUE, 
                    customstopwords=NULL)


meta<-temp$meta
vocab<-temp$vocab
docs<-temp$documents

forum_topics_15 <-stm(documents=docs, 
       vocab=vocab, 
       K=15,
       data=meta, 
       max.em.its=100,
       verbose = FALSE)

plot(forum_topics_15)

toLDAvis(mod = forum_topics_15, 
         docs = docs)

forum_topics_15 <-stm(documents=docs, 
                      vocab=vocab, 
                      K=15,
                      data=meta, 
                      max.em.its=100,
                      verbose = FALSE)

plot(forum_topics_15)

toLDAvis(mod = forum_topics_15, 
         docs = docs)

#removes documents from original data source that were removed during processing so you can use findThoughts
z <-ts_forum_data$post_content[-temp$docs.removed]
length(z)

findThoughts(forum_topics_15,
             texts = z,
             topics = 10, 
             n = 5,
             thresh = 0.0)





forums_lda <- LDA(forums_dtm, 
                  k = 15, 
                  control = list(seed = 123))

forums_lda

forum_topics <- tidy(forums_lda, matrix = "beta")

forums_lda %>%
  tidy() %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, ncol = 2, scales = "free") +
  scale_y_reordered()





# testing dtm from tidy

stemmed_dtm <- ts_forum_data %>%
  unnest_tokens(output = word, input = post_content) %>%
  anti_join(stop_words, by = "word") %>%
  mutate(stem = wordStem(word)) %>%
  count(post_id, stem, sort = TRUE) %>%
  cast_dtm(post_id, stem, n)

stemmed_dtm

forum_topics_5 <-stm(stemmed_dtm, 
                      K=5,
                      max.em.its=25,
                      verbose = FALSE)

library(ldatuning)

k_metrics <- FindTopicsNumber(
  forums_dtm,
  topics = seq(10, 75, by = 5),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(),
  mc.cores = NA,
  return_models = FALSE,
  verbose = FALSE,
  libpath = NULL
)

FindTopicsNumber_plot(k_metrics)
