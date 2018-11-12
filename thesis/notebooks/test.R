setwd('C:/My/_DropboxSync/Dropbox/Playground/Jupyter/notebook/Thesis')
data <- read.csv('mycsv.csv')
head(data); nrow(data)
data <- data[,2:4]


glm(y ~ x1 + x2, data=data, family = "binomial")
