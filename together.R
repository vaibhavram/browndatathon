library(tidyverse)
library(stringr)

setwd("/Users/vaibhav/Documents/Year4_Senior/Brown Datathon 2018/browndatathon/")

abstracts <- read.csv("abstracts.csv", stringsAsFactors = FALSE)
ratings <- read.csv("ratings.csv", stringsAsFactors = FALSE)

abstracts <- abstracts[,2:ncol(abstracts)]
ratings <- ratings[,2:ncol(ratings)]

data <- ratings %>%
  left_join(abstracts, by = c("manuscript_DOI" = "doi"))

data$abstract_nchar <- nchar(data$abstract)
data$abstract_num_digits <- str_count(data$abstract, "0") + str_count(data$abstract, "1") +
  str_count(data$abstract, "2") + str_count(data$abstract, "3") + str_count(data$abstract, "4") +
  str_count(data$abstract, "5") + str_count(data$abstract, "6") + str_count(data$abstract, "7") +
  str_count(data$abstract, "8") + str_count(data$abstract, "9") 
data$abstract_has_digits <- data$abstract_num_digits > 0
data$abstract_findings_results <- str_count(data$abstract, "result") + 
  str_count(data$abstract, "finding") + str_count(data$abstract, "Result") + 
  str_count(data$abstract, "Finding")

data$version_id <- as.factor(data$version_id)  
data$year <- as.factor(data$year)

lm1 <- lm(discovery_value ~ abstract_nchar + abstract_num_digits + 
            abstract_has_digits + abstract_findings_results + version_id + year + expertise, data)  
  
  