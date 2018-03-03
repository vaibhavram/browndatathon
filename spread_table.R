library(tidyverse)

setwd("/Users/vaibhav/Documents/Year4_Senior/Brown Datathon 2018/browndatathon/")

data <- read.csv("Data/DiscoveryEngine/DiscoveryEngine_Dataset_2_28_2018.csv", stringsAsFactors = FALSE)
data <- unique(data[,2:8])
data$question_id[data$question_id > 4] <- data$question_id[data$question_id > 4] - 4
data$question_id[data$question_id == 1] <- "discovery_value"
data$question_id[data$question_id == 2] <- "actionability"
data$question_id[data$question_id == 3] <- "concreteness_confidence"
data$question_id[data$question_id == 4] <- "expertise"

new_data <- dcast(data, create_date + version_id + user_id + manuscript_id + manuscript_DOI ~ question_id,
                  value.var = "rating", fun.aggregate = mean, na.rm = TRUE)

write.csv(new_data, "ratings.csv")
