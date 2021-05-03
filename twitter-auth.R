install.packages("devtools")
library(devtools)
devtools::install_github("cjbarrie/academictwitteR", build_vignettes = FALSE)

library(academictwitteR)
library(rtweet)

bearer_token <- "AAAAAAAAAAAAAAAAAAAAAJ%2FrOwEAAAAAsaw6PMYB%2FnQebCPKkDC0BvNOvbU%3DRT3uqorZy3ho9zeTGu4Haulq2xEvB6MuObmzjSTikRnXhcrjDB" # Insert bearer token from developer.twitter.com

## store api keys (these are fake example values; replace with your own keys from developer.twitter.com) and authenticate via web browser

token <- create_token(
  app = "LASER Labs",
  consumer_key = "RmHMiBvdYpBsFlc1BLxAqf7bL",
  consumer_secret = "5eGV5dZvk6v1zzDcBDO8EbBpkdQDLoFSnB4XHN3lXcflWXdCcx",
  access_token = "17572410-GrKEvzcN3Jktf5ED9QbLaYVGnGWd5sOuQ5zxA2wWa",
  access_secret = "ZfkoPNOcHiUQfSh4zEHr0VCTGAZDRalvfLkpoSxnRvfR6")

get_token()
