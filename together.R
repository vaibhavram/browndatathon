library(tidyverse)
library(stringr)

setwd("/Users/vaibhav/Documents/Year4_Senior/Brown Datathon 2018/browndatathon/")

abstracts <- read.csv("abstracts.csv", stringsAsFactors = FALSE)
ratings <- read.csv("ratings.csv", stringsAsFactors = FALSE)

abstracts <- abstracts[,2:ncol(abstracts)]
ratings <- ratings[,2:ncol(ratings)]

data <- ratings %>%
  left_join(abstracts, by = c("manuscript_DOI" = "doi")) %>%
  filter(year > 0)

data$abstract_nchar <- nchar(data$abstract)
data$abstract_num_digits <- str_count(data$abstract, "0") + str_count(data$abstract, "1") +
  str_count(data$abstract, "2") + str_count(data$abstract, "3") + str_count(data$abstract, "4") +
  str_count(data$abstract, "5") + str_count(data$abstract, "6") + str_count(data$abstract, "7") +
  str_count(data$abstract, "8") + str_count(data$abstract, "9") 
data$abstract_has_digits <- data$abstract_num_digits > 0
data$abstract_findings_results <- str_count(data$abstract, "result") + 
  str_count(data$abstract, "finding") + str_count(data$abstract, "Result") + 
  str_count(data$abstract, "Finding")
data$dv_words <- str_count(data$abstract, "transform") + 
  str_count(data$abstract, "importan") + str_count(data$abstract, "discover") + 
  str_count(data$abstract, "new") + str_count(data$abstract, "innovat") + 
  str_count(data$abstract, "chang") + str_count(data$abstract, "potential") + 
  str_count(data$abstract, "breakthrough")
data$act_words <- str_count(data$abstract, "use") + 
  str_count(data$abstract, "relevan") + str_count(data$abstract, "applicab") + 
  str_count(data$abstract, "utility") + str_count(data$abstract, "utiliz") + 
  str_count(data$abstract, "suit") + str_count(data$abstract, "action")
data$con_words <- str_count(data$abstract, "accura") + 
  str_count(data$abstract, "confirm") + str_count(data$abstract, "ground") + 
  str_count(data$abstract, "confiden") + str_count(data$abstract, "concrete") + 
  str_count(data$abstract, "truth")

data$version_id <- as.factor(data$version_id)  
data$year <- as.factor(data$year)

lm_dv <- lm(discovery_value ~ abstract_nchar + abstract_num_digits + 
            abstract_has_digits + abstract_findings_results + version_id + year + expertise +
            dv_words + act_words + con_words, data)  
lm_act <- lm(actionability ~ abstract_nchar + abstract_num_digits + 
              abstract_has_digits + abstract_findings_results + version_id + year + expertise +
              dv_words + act_words + con_words, data)  
lm_con <- lm(concreteness_confidence ~ abstract_nchar + abstract_num_digits + 
              abstract_has_digits + abstract_findings_results + version_id + year + expertise +
              dv_words + act_words + con_words, data)  
summary(lm_dv)
summary(lm_act)
summary(lm_con)


######
View(data %>%
  group_by(user_id) %>%
  summarize(count = n()) %>%
  arrange(desc(count)))
