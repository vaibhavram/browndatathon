# TextVisual.R
library(tm)
library(reshape2)
library(dplyr)
library(scatterplot3d)
setwd("~/Desktop/datathon/brown/browndatathon")
df <- read.csv("together_data.csv", stringsAsFactors = F)

df$abstract <- gsub("[^a-zA-Z]+", " ", df$abstract)
corpus <- paste(df$abstract, collapse = " ")
noStopCorp <- removeWords(corpus, stopwords())
noStopCorp <- tolower(removePunctuation(removeNumbers(noStopCorp)))
noStopCorp <- gsub("\\s+", " ",noStopCorp)
cleanCorp <- stemDocument(noStopCorp)

allWords <- unlist(strsplit(cleanCorp, split = " "))
uniqWords <- unique(allWords)

# First averaging scores by document
scores <- df[ ,c("abstract", "manuscript_id","discovery_value", "actionability", "concreteness_confidence")]

scores <-
  scores %>% group_by(manuscript_id) %>%
  summarise(avgDV = mean(discovery_value), avgAct = mean(actionability),
            avgCC = mean(concreteness_confidence))

scores <- inner_join(scores, unique(df[ ,c("abstract", "manuscript_id")]),
                     by = "manuscript_id")
# Creating presence Corpus
presenceCorp <- data.frame()

for (i in 1:length(uniqWords)) {
  if (i %% 100 == 0) {
    cat("Finished", i, "th word presence finding..\n")
  }
  presence <- 
    sapply(1:length(scores$abstract), function(j) {
    grepl(uniqWords[i], scores$abstract[j], ignore.case = T)
  })
  avgScores <- apply(scores[presence, c("avgDV", "avgAct", "avgCC")], 
                     2, function(x) mean(x[1]))
  presenceCorp <- rbind(presenceCorp, avgScores)
}
presenceCorp['word'] <- uniqWords
colnames(presenceCorp) <- c('avgDV', 'avgAct', 'avgCC', 'word')

presenceCorp <- presenceCorp[!is.na(presenceCorp$avgAct), ]

saveRDS(presenceCorp, file = "wordScoreMat.rds")

presenceCorp <- readRDS(file = "wordScoreMat.rds")
x <- presenceCorp[,1]
y <- presenceCorp[,2]
z <- presenceCorp[,3]
ptext3d(presenceCorp[,1:3], text = presenceCorp$word)
