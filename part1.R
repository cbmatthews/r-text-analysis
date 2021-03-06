#DATA INPUT SECTION
setwd("D:/data/DATA650/Assignment1/data")

docs <-Corpus(DirSource("."))

#PREPROCESSING SECTION
docs<-tm_map(docs, stripWhitespace)
docs<-tm_map(docs, removePunctuation)

toSpace <-content_transformer(function(x, pattern)gsub(pattern = "", x))
docs<-tm_map(docs, toSpace, "@")

docs<-tm_map(docs, removeNumbers)
docs<-tm_map(docs, tolower)

docs<-tm_map(docs, removeWords, stopwords("english"))

docs<-tm_map(docs, removeWords, stopwords("SMART"))

inspect(docs[[3]])

#STEMMING SECTION
library(SnowballC)

docs<-tm_map(docs, stemDocument)

#GET WORD FREQUENCY
dtm<-DocumentTermMatrix(docs)
dtm

freq<-colSums(as.matrix(dtm))
freq
length(freq)

m<- as.matrix(dtm)

dim(m)

findFreqTerms(dtm, lowfreq = 10)

dtms<-removeSparseTerms(dtm, 0.7)
dtms

#TERM ASSOCIATIONS
findAssocs(dtm("design", "tool", "success"), corlimit=0.75)

#CORRELATION PLOTS
source("http://bioconductor.org/biocLite.R")
biocLite("Rgraphviiz")

plot(dtm, terms=findFreqTerms(dtm, lowfreq=5)[1:15], corThreshold=0.5)

plot(dtm, terms=findFreqTerms(dtm, lowfreq=10)[1:6], corThreshold=0.2, weighting = T)

#WORD FREQUENCY PLOTS
library(ggplot2)
wf <- data.frame(word=names(freq), freq=freq)
p <- ggplot(subset(wf, freq>5), aes(word, freq))
p <- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))
p

#WORD CLOUD
library(wordcloud)

wordcloud(names(freq), freq, min.freq=5)

dtms <- removeSparseTerms(dtm, 0.7) # Prepare the data (max 70% empty space)   
freq <- colSums(as.matrix(dtm)) # Find word frequencies   
dark2 <- brewer.pal(6, "Dark2")   
wordcloud(names(freq), freq, max.words=100, rot.per=0.2, colors=dark2)

#K-MEANS CLUSTERING
library(cluster)
dtms <- removeSparseTerms(dtm, 0.75) 
d <- dist(t(dtms), method="euclidian")   
kfit <- kmeans(d, 4)   
clusplot(as.matrix(d), kfit$cluster, color=T, shade=T, labels=2, lines=0)
kfit

bss<-integer(length(2:15))
for (i in 2:15) bss[i] <- kmeans(d,centers=i)$betweenss
plot(1:15, bss, type="b", xlab="Number of Clusters",  ylab="Sum of squares", col="blue") 
wss<-integer(length(2:15))
for (i in 2:15) wss[i] <- kmeans(d,centers=i)$tot.withinss
lines(1:15, wss, type="b" )

#CLUSTER DENDOGRAM
library(cluster)
library(fpc)

dtms <- removeSparseTerms(dtm, 0.8)
d <- dist(t(dtms), method="euclidian")
fit <- hclust(d=d, method="ward.D2")
plot(fit, hang=-1)

plot.new()
plot(fit, hang=-1)
groups <- cutree(fit, k=4)
rect.hclust(fit, k=4, border="red")

