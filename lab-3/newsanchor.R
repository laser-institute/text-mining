# ___________________________
# Script name: newsanchor package
# Purpose of script: example for optional meeting
# Author: Shaun Kellogg
# Date Created: 
# ___________________________
# Notes:
# 
# 
# ___________________________

library(newsanchor)
library(dplyr)

set_api_key(tempdir())


search_terms <- c()


sources <- get_sources()
sources <- sources$results_df

View(sources)

publications <- sources %>%
  filter(country == "us", 
         language == "en",
         category == "general", 
         ! id %in% c("vice-news",
                     "reddit-r-all",
                     "al-jazeera-english",
                     "breitbart-news",
                     "politico")
  )

publications <- publications$id


publications <- c("the-washington-post", "fox-news", "axios", "reuters", )

search_terms <- 


results <- get_everything_all(query = "student learning loss",
                              language = "en",
                              sort_by = "relevancy",
                              #sources = publications
)

articles <- results$results_df
View(articles)


metadata <- results$metadata
metadata