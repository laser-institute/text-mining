

# 1. PREPARE ####

## a) Context ####

### load packages ####

library (tidyverse)
library(tidytext)
library(readr)

## b) Data ####

### Read and View Data ####

#### Read Data into R ####

#opd_survey <- read_csv("unit-1/data/opd_survey.csv")

opd_survey <- read_csv("/Volumes/GoogleDrive/My Drive/College of Ed/Data/opd_survey.csv")
View(opd_survey)

?read_csv


#### View Data in R ####

#' There are many different ways to look at your data in R. For example, you can: 

# enter the name of your data frame and view directly in console 
opd_survey 

# view your data frame transposed so your can see every column and the first few entries

glimpse(opd_survey) 

# look at just the first six entries
glimpse(opd_survey) 

# or the last six entries
tail(opd_survey) 

# view the names of your variables or columns
names(opd_survey) 

# or view in source pane
view(opd_survey) 



## c) Question ####

#' What can basic text mining techniques tell us about the most 
#' valuable aspects of online professional development offerings to teachers? 


# 2. WRANGLE DATA #### 

## a) Data Reduction ####

# subset role and Q21 coulumns and store as new dataframe
opd_selected <- select(opd_survey, Role, Resource, Q21)

# rename Q21 to Value
opd_renamed <- rename(opd_selected, text = Q21)

# remove rows 1 and 2 
opd_sliced <- slice(opd_renamed, -1, -2)

# subset rows where the Role column contains Teaccher
opd_teacher <- filter(opd_sliced, Role == "Teacher")

opd_teacher

# Let's use the pipe operator to simplify this code. 


opd_teacher <- opd_survey %>%
  select(Role, Resource, Q21) %>%
  rename(text = Q21) %>%
  slice(-1, -2) %>%
  filter(Role == "Teacher") %>%
  na.omit()

glimpse(opd_teacher)


## b) Tidy Text ####

### Tokenize Text ####

opd_test <- slice(opd_teacher, 1:10000)

opd_tidy <- unnest_tokens(opd_teacher, word, text)

opd_tidy

### Remove Stop Words ####

data(stop_words)

opd_clean <- anti_join(opd_tidy, stop_words)

view(opd_clean)


# 3. EXPLORE #### 

## a) Summary Stats ####

### word counts ####

opd_counts <- count(opd_clean, word, sort = TRUE)

view(opd_counts)

opd_resource_counts <- opd_clean %>%
  count(Resource, word)

view(opd_resource_counts)

resource_counts <- count(opd_clean, Resource, sort = T)
resource_counts


### word search ####
view(filter(opd_teacher, grepl('examp*', text)))


### word frequencies ####
opd_frequencies <- opd_clean %>%
  count(Resource, word) %>%
  group_by(Resource) %>%
  mutate(proportion = n / sum(n))

view(opd_frequencies)


### tf-idf ####
opd_resource_counts <- opd_clean %>%
  count(Resource, word)

total_words <- opd_resource_counts %>%
  group_by(Resource) %>%
  summarize(total = sum(n))

total_words

opd_words <- left_join(opd_resource_counts, total_words)

opd_words

view(opd_words)

opd_tf_idf <- opd_words %>%
  bind_tf_idf(word, Resource, n)

opd_tf_idf

view(opd_tf_idf)

## b) Data Viz #### 

### bar plot counts ####

library(ggplot2)

opd_counts %>%
  filter(n > 500) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col()


### word cloud #### 

library(wordcloud)
library(wordcloud2)

opd_counts %>%
  with(wordcloud(word, n, max.words = 100))

colorVec = rep(c('black', 'gray'), length.out=nrow(opd_counts))
wordcloud2(opd_counts, color = colorVec, fontWeight = "bold")

wordcloud2(opd_counts,
           color = ifelse(opd_counts[, 2] > 1000, 'black', 'gray'))

### facets ####

library(forcats)

opd_frequencies %>%
  group_by(Resource) %>%
  slice_max(proportion, n = 5) %>%
  ungroup() %>%
  ggplot(aes(proportion, fct_reorder(word, proportion), fill = Resource)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Resource, ncol = 3, scales = "free")

opd_frequencies %>%
  group_by(Resource) %>%
  slice_max(proportion, n = 4) %>%
  ungroup() %>%
  ggplot(aes(proportion, word, fill = Resource)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Resource, ncol = 3, scales = "free")

opd_frequencies %>%
  filter(Resource == "Online Learning Module (e.g. Call for Change, Understanding the Standards, NC Falcon)") %>%
  slice_max(proportion, n = 10) %>%
  ggplot(aes(proportion, fct_reorder(word, proportion))) +
  geom_col(show.legend = FALSE)

opd_frequencies %>%
  filter(Resource == "Online Learning Module (e.g. Call for Change, Understanding the Standards, NC Falcon)") %>%
  slice_max(proportion, n = 10) %>%
  ggplot(aes(proportion, word)) +
  geom_col()


### tf-idf ####

library(forcats)

opd_tf_idf %>%
  filter(Resource != "Calendar") %>%
  group_by(Resource) %>%
  slice_max(tf_idf, n = 5) %>%
  ungroup() %>%
  ggplot(aes(tf_idf, fct_reorder(word, tf_idf), fill = Resource)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Resource, ncol = 3, scales = "free") +
  labs(x = "tf-idf", y = NULL)




