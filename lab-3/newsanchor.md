The newsanchor Package
========================================================
author: Shaun Kellogg
date: 03/25/21
autosize: false 

Step 1: Registration & API KEY
========================================================

- Visit https://newsapi.org and click "Get API Key."
- Register your account.
- Voila, your API key should appear!  

Step 2: Install and Load newsanchor
========================================================


```r
install.packages("newsanchor")
```


```r
library(newsanchor)
```

Step 2: Set you API Key
========================================================
- Run the following code.
- You will be prompted to enter your API key.


```r
set_api_key(tempdir())
```

Step 3: Set you API Key
========================================================
- Run the following code.
- You will be prompted to enter your API key.
- You should only have to do this once. 


```r
set_api_key(tempdir())
```

Step 4: View Available Sources
========================================================


```r
sources <- get_sources()
sources <- sources$results_df

View(sources)
```

Step 5: Get Articles
========================================================


```r
results <- get_everything_all(query = "students learning loss",
                              language = "en",
                              sort_by = "relevancy",
                              #sources = publications
)

articles <- results$results_df

View(articles)
```
