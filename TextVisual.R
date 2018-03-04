# TextVisual.R
library(tm)
setwd("~/Desktop/datathon/brown/browndatathon")
df <- read.csv("together_data.csv", stringsAsFactors = F)

corpus <- paste(df$abstract, collapse = " ")
noStopCorp <- removeWords(corpus, stopwords())
noStopCorp <- tolower(removePunctuation(removeNumbers(noStopCorp)))
cleanCorp <- stemDocument(noStopCorp)

allWords <- unlist(strsplit(cleanCorp, split = " "))
uniqWords <- unique(allWords)

i = 1
presenceCorp <- data.frame()

for (i in (1:5)) {
  presence <- 
    sapply(1:length(df$abstract), function(j) {
    grepl(uniqWords[i], df$abstract[j], ignore.case = T)
  })
  presenceCorp <- cbind(presenceCorp, presence)
}
