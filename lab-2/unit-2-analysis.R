#' ---------------------------
#' Script name: Twitter Sentiment
#' Purpose of script: 
#' Author: Dr. Shaun Kellogg
#' Date Created: 2021-02-19
#' ---------------------------
#' Notes:
#' 
#' 
#' ---------------------------



# 1. PREPARE ####

## Load Packages ####

library(dplyr)
library(tidyr)
library(rtweet)
library(tidytext)
library(ggplot2)
library(textdata)
library(scales)

library(devtools)
devtools::install_github("gadenbuie/tweetrmd")


## store api keys (these are fake example values; replace with your own keys)
app_name <- "XXXXXXXXXXXXXXX"
api_key <- "XXXXXXXXXXXXXXX"
api_secret_key <- "XXXXXXXXXXXXXXX"
access_token <- "XXXXXXXXXXXXXXX"
access_token_secret <- "XXXXXXXXXXXXXXX"

## authenticate via web browser

token <- create_token(
  app = app_name,
  consumer_key = api_key,
  consumer_secret = api_secret_key,
  access_token = access_token,
  access_secret = access_token_secret)

get_token()


# 2. WRANGLE #### 

## Import Tweets ####

### search_tweets ####


ngss_all_tweets <- search_tweets("#NGSSchat", n=1000)

# include_rts = FALSE

ngss_non_retweets <- search_tweets("#NGSSchat", 
                             n=1000, 
                             include_rts = FALSE)

# include multiple search terms

ngss_or_tweets <- search_tweets("#NGSSchat OR ngss", 
                             n=5000,
                             include_rts = FALSE)

### search_tweets2 ####

ngss_tweets <- search_tweets2(c("#NGSSchat OR ngss",
                                   "\"next generation science standard\"",
                                   "\"next generation science standards\"",
                                   "\"next gen science standard\"",
                                   "\"next gen science standards\""
                                   ), 
                             n=5000,
                             include_rts = FALSE)

### ngss dictionary ####

ngss_dictionary <- c("#NGSS OR #NGSSchat OR ngss",
                     "\"next generation science standard\"",
                     "\"next generation science standards\"",
                     "\"next gen science standard\"",
                     "\"next gen science standards\""
)


ngss_tweets <- search_tweets2(ngss_dictionary, 
                              n=5000, 
                              include_rts = FALSE)


### ccss dictionary ####


ccss_dictionary <- c("#commoncore", "\"common core\"")


ccss_tweets <- search_tweets2(ccss_dictionary, 
                              n=5000, 
                              include_rts = FALSE)



#### other useful arguments ####
ngss_geo_tweets <- search_tweets("#NGSS",
                             "lang:en", 
                             geocode = lookup_coords("usa"), 
                             n = 1000, 
                             type="recent", 
                             include_rts=FALSE)

glimpse(ngss_tweets)

view(ngss_tweets)



### get_timeline ####

fi <- c("sbkellogg", "mjsamberg", "haspires", "tarheel93", "drcallie_tweets", "AlexDreier")

# filter retweets 

fi_tweets <- get_timeline(fi)

fi_tweets <- get_timelines(fi, include_rts=FALSE)

fi_tweets <- fi %>%
  get_timelines(include_rts=FALSE)

fi_tweets <- get_timelines(fi) %>%
  filter(is_retweet == FALSE)

glimpse(fi_tweets)


my_timeline <- get_my_timeline(n = 500)



## Tidy Tweets ####



ngss_text <-
  ngss_tweets %>%
  filter(lang == "en") %>% #filter for English tweets
  mutate(status_id = as.character(status_id)) %>% # Convert the ID field to the character data type 
  mutate(standards = "ngss") %>%
  select(standards, screen_name, created_at, text)


ccss_text <-
  ccss_tweets %>%
  filter(lang == "en") %>% #filter for English tweets
  mutate(status_id = as.character(status_id)) %>% # Convert the ID field to the character data type 
  mutate(standards = "ccss") %>%
  select(standards, screen_name, status_id, text)


### Combine Data Sets #### 

tweets <- bind_rows(ngss_text, ccss_text)


### unnest_tokens ####

tweet_tokens <- 
  tweets %>%
  unnest_tokens(output = word, input = text)

#### tokens = "tweets" ####

tweet_tokens <- 
  tweets %>%
  unnest_tokens(output = word, input = text, token = "tweets")


### remove stop words ####

data(stop_words)

tidy_tweets <-
  tweet_tokens %>%
  anti_join(stop_words, by = "word")


count(tweet_stopped, word, sort = T)

### custom stop words ####

tidy_tweets <-
  tweet_tokens %>%
  anti_join(stop_words) %>%
  filter(!(word == "https"|
             word == "t.co"|
             word == "amp"))

### Julia's Code 

remove_reg <- "&amp;|&lt;|&gt;"

tidy_tweets <- tweets %>% 
  filter(!str_detect(text, "^RT")) %>%
  mutate(text = str_remove_all(text, remove_reg)) %>%
  unnest_tokens(word, text, token = "tweets") %>%
  filter(!word %in% stop_words$word,
         !word %in% str_remove_all(stop_words$word, "'"),
         str_detect(word, "[a-z]"))



## Get Sentiments ####

### get_sentiments ####

get_sentiments("afinn")

1 

get_sentiments("bing")


get_sentiments("nrc")

1

get_sentiments("loughran")


sentiment_afinn <- tidy_tweets %>% 
  inner_join(get_sentiments("afinn"))

sentiment_bing <- tidy_tweets %>% 
  inner_join(get_sentiments("bing"))

sentiment_nrc <- tidy_tweets %>% 
  inner_join(get_sentiments("nrc"))

sentiment_loughran <- tidy_tweets %>% 
  inner_join(get_sentiments("loughran"))


# 3. EXPLORE ####

## Word Counts ####

word_counts <- tidy_tweets %>% 
  count(standards, word, sort = TRUE)

word_counts %>%
  filter(n > 50, standards == "ccss") %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col()

standard_counts <- tidy_tweets %>% 
  count(standards, word, sort = TRUE)

### bar plots ####

word_counts %>%
  filter(standards == "ccss") %>%
  slice_max(n, n = 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col()

word_counts %>%
  filter(standards == "ngss") %>%
  slice_max(n, n = 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col()


## Word Frequency ####

frequency <- tidy_tweets %>% 
  group_by(standards) %>% 
  count(word, sort = TRUE) %>% 
  left_join(tidy_tweets %>% 
              group_by(standards) %>% 
              summarise(total = n())) %>%
  mutate(freq = n/total * 100)


### scatterplot ####

frequency <- frequency %>% 
  select(standards, word, freq) %>% 
  spread(standards, freq) %>%
  arrange(ngss, ccss)

ggplot(frequency, aes(ngss, ccss)) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.25, height = 0.25) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")

  
frequency %>%
  group_by(standards) %>%
  slice_max(freq, n = 15) %>%
  ungroup() %>%
  mutate(word = reorder(word, freq)) %>%
  ggplot(aes(freq, word, fill = standards)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~standards, ncol = 3, scales = "free")


frequency %>%
  group_by(standards) %>%
  slice_max(freq, n = 15) %>%
  ungroup() %>%
  mutate(standards=as.factor(standards),
         word=reorder_within(word, freq, standards)) %>%
  ggplot(aes(word, freq, fill = standards)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~standards, ncol = 3, scales = "free") + 
  coord_flip() +
  scale_x_reordered()



## Sentiment Analysis ####

### summarize sentiment scores ####

summary_afinn1 <- sentiment_afinn %>% 
  summarise(sentiment = sum(value)) %>% 
  mutate(method = "AFINN")

summary_afinn2 <- sentiment_afinn %>% 
  group_by(standards) %>% 
  summarise(sentiment = sum(value)) %>% 
  mutate(method = "AFINN")

summary_bing1 <- sentiment_bing %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "bing")

summary_bing2 <- sentiment_bing %>% 
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "bing")

summary_bing3 <- sentiment_bing %>% 
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "bing")  %>%
  spread(sentiment, n) %>%
  mutate(sentiment = positive - negative)

summary_nrc1 <- sentiment_nrc %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "nrc")

summary_nrc2 <- sentiment_nrc %>% 
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "nrc")

summary_nrc3 <- sentiment_nrc %>% 
  filter(sentiment %in% c("positive", "negative")) %>%
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "nrc")  %>%
  spread(sentiment, n) %>%
  mutate(sentiment = positive - negative)

summary_loughran1 <- sentiment_loughran %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "loughran")

summary_loughran2 <- sentiment_loughran %>% 
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "loughran")

summary_loughran3 <- sentiment_loughran %>% 
  filter(sentiment %in% c("positive", "negative")) %>%
  group_by(standards) %>% 
  count(sentiment, sort = TRUE) %>% 
  mutate(method = "loughran")  %>%
  spread(sentiment, n) %>%
  mutate(sentiment = positive - negative)

summary_sentiment <- bind_rows(summary_bing3,
                               summary_nrc3,
                               summary_loughran3) %>%
  arrange(method, standards) %>%
  mutate(positive_ratio = positive/negative)

summary_sentiment


### over time ####






frequency <- sentiment_bing %>% 
  filter(sentiment == "negative") %>%
  group_by(standards) %>% 
  count(word, sort = TRUE) %>% 
  left_join(sentiment_bing %>% 
              group_by(standards) %>% 
              summarise(total = n())) %>%
  mutate(freq = n/total * 100)


### scatterplot ####

frequency <- frequency %>% 
  select(standards, word, freq) %>% 
  spread(standards, freq) %>%
  arrange(ngss, ccss)

ggplot(frequency, aes(ngss, ccss)) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.25, height = 0.25) +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(color = "red")
