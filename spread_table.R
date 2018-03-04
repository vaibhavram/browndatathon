library(tidyverse)

setwd("/Users/vaibhav/Documents/Year4_Senior/Brown Datathon 2018/browndatathon/")

data <- read.csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv", stringsAsFactors = FALSE)
data <- unique(data[,2:8])
data$question_id[data$question_id > 4] <- data$question_id[data$question_id > 4] - 4
data$question_id[data$question_id == 1] <- "discovery_value"
data$question_id[data$question_id == 2] <- "actionability"
data$question_id[data$question_id == 3] <- "concreteness_confidence"
data$question_id[data$question_id == 4] <- "expertise"
data$create_date <- as.POSIXct(data$create_date, format = "%m/%d/%Y %H:%M", tz = "GMT")

data2 <- data %>%
  group_by(question_id, user_id, manuscript_id, manuscript_DOI) %>%
  summarize(max(create_date))
names(data2)[ncol(data2)] <- "create_date"
data2 <- data2 %>%
  left_join(data, by = c("question_id" = "question_id", "create_date" = "create_date", 
                         "user_id" = "user_id", "manuscript_id" = "manuscript_id", 
                         "manuscript_DOI" = "manuscript_DOI")) %>%
  arrange(manuscript_id, user_id, question_id)

data3 <- data2 %>% ungroup() %>%
  group_by(question_id, user_id, manuscript_id, manuscript_DOI, version_id, create_date) %>%
  summarize(rating = max(rating))

new_data <- dcast(data3, create_date + version_id + user_id + manuscript_id + manuscript_DOI ~ question_id,
                  value.var = "rating", fun.aggregate = mean, na.rm = TRUE)

write.csv(new_data, "ratings.csv")

