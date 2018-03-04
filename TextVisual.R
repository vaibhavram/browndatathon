# TextVisual.R
library(tm)
library(reshape2)
library(dplyr)
library(plotly)
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
numAppear <- c()
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
  numAppear <- c(numAppear, sum(presence))
}
presenceCorp['word'] <- uniqWords
presenceCorp['numAppear'] <- numAppear
colnames(presenceCorp) <- c('avgDV', 'avgAct', 'avgCC', 'word', 'numAppear')

presenceCorp <- presenceCorp[!is.na(presenceCorp$avgAct), ]

presenceCorp[,1:3] <- 
  apply(presenceCorp[,1:3], 2, function(x) {
  round(x, 2)
})

saveRDS(presenceCorp, file = "wordScoreMat.rds")

presenceCorp <- readRDS(file = "wordScoreMat.rds")

distMat <- 
  apply(presenceCorp[,1:3], 2, function(x) {
  (x - mean(x)) / sd(x)
})
distMat <- data.frame(distMat)
distMat['word'] <- presenceCorp['word']
distMat['numAppear'] <- presenceCorp['numAppear']

sigMat <- distMat[ (abs(distMat[,1]) >= 2) | (abs(distMat[,2]) >= 2) | abs(distMat[,3] >= 2), ]

# with(sigMat,plot3d(x,y,z))
# with(presenceCorp,text3d(x,y,z,presenceCorp$word, font = 1))


plot_ly(presenceCorp, x = ~avgDV, y = ~avgAct, z = ~avgCC,
        text = ~paste0("(",avgDV, ",", avgAct, ",", avgCC, ")",
                       "<br>Word: ", word, 
                       "<br>num:", numAppear), 
        hoverinfo = "text", color = ~log(numAppear),
        marker = list(size =6)) %>%
  layout(title = "Average Ratings for each Word, by Category (axis)",
         scene = list(xaxis = list(title = 'Discovery'),
                      yaxis = list(title = 'Actionable'),
                      zaxis = list(title = 'Concrete')))


