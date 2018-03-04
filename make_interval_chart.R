library(tidyverse)

setwd("/Users/vaibhav/Documents/Year4_Senior/Brown Datathon 2018/browndatathon/")

ratings <- read.csv("ratings.csv", stringsAsFactors = FALSE)
ratings <- ratings[,2:ncol(ratings)]
ratings <- ratings %>%
  arrange(user_id, create_date)
