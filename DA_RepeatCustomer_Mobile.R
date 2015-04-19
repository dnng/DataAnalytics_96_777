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
#get repeat CSP 
rpCSP <- txdata[which(duplicated(txdata$CSP_Code)),]
rpCSP <- txdata[which(txdata$CSP_Code %in% rpCSP$CSP_Code),]
#get repeat Customer from repeat CSP
rpCustomer <- rpCSP[which(duplicated(rpCSP$Depositor_Mobile)),]
rpCustomer <- rpCSP[which(rpCSP$Depositor_Mobile %in% rpCustomer$Depositor_Mobile),]
#sort repeat Cusomer who goes to the same CSP by Mobile Number (Customer ID)
rpCustomer <- rpCustomer[order(rpCustomer$Depositor_Mobile),]

#for each CSP_Code, count the number of different Depositor_Mobile
rpCustomer.csp_code.depositor_mb <- data.frame(rpCustomer$CSP_Code, rpCustomer$Depositor_Mobile)
tbRpCs <- unique(rpCustomer.csp_code.depositor_mb)
tbRpCSC <- count(tbRpCs, vars = "rpCustomer.CSP_Code")
qplot(rpCustomer.CSP_Code, data=tbRpCs, geom="histogram")


rpDist <- count(rpCustomer, vars = "Depositor_Mobile")
rpCountDist <- count(rpDist, vars = "freq")
colnames(rpCountDist) <- c("RepeatTimes", "Count")

qplot(RepeatTimes, Count, data=rpCountDist)
qplot(RepeatTimes, Count, data=rpCountDist, size=Count)
qplot(RepeatTimes, Count, data=rpCountDist, geom = c("line","point"))
