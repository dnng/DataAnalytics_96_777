setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

txdata = read.csv("Dec2014_SBI.csv", header = TRUE)
#txdata_1 = read.csv("JanD2C_2015.csv", header = TRUE)
#txdata_2 = read.csv("FebD2C_2015.csv", header = TRUE)
str(txdata)
txdata$CSP_Code <- as.factor(txdata$CSP_Code)
txdata$SBI_Account <- as.factor(txdata$SBI_Account)
str(txdata)
summary(txdata)
rpCSP <- txdata[which(duplicated(txdata$CSP_Code)),]
rpCSP <- txdata[which(txdata$CSP_Code %in% rpCSP$CSP_Code),]
rpCustomer <- rpCSP[which(duplicated(rpCSP$SBI_Account)),]
rpCustomer <- rpCSP[which(rpCSP$SBI_Account %in% rpCustomer$SBI_Account),]
head(rpCustomer[order(rpCustomer$SBI_Account),], 10)
summary(rpCustomer)
dim(rpCustomer)
head(rpCSP[which(rpCSP$SBI_Account %in% rpCustomer$SBI_Account),], 5)

rpDist <- count(rpCustomer, vars = "SBI_Account")
rpCountDist <- count(rpDist, vars = "freq")
colnames(rpCountDist) <- c("RepeatTimes", "Count")

qplot(RepeatTimes, Count, data=rpCustomer, geom = c("line","point"))
qplot(RepeatTimes, Count, data=rpCountDist)
qplot(RepeatTimes, Count, data=rpCountDist, size=Count)
qplot(RepeatTimes, Count, data=rpCountDist, geom = c("line","point"))
