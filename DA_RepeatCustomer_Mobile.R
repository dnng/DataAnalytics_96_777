setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

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
rpCustomer$numOfSwitch <- rep(0, nrow(rpCustomer))
# ===== get fickle customer =====
#   ===== get repeat customer (customer who has multiple transaction data)  ====
fkCustomer <- txdata[which(duplicated(txdata$Depositor_Mobile)),]
fkCustomer <- txdata[which(txdata$Depositor_Mobile %in% fkCustomer$Depositor_Mobile),]
fkCustomer <- fkCustomer[order(fkCustomer$Depositor_Mobile),]
#   ===== get transaction data with the same customer ID, but different CSP_Code  ==== 
agentsFkCustomer <- data.frame(fkCustomer$CSP_Code, fkCustomer$Depositor_Mobile)
agentsFkCustomer <- unique(agentsFkCustomer)
numOfAgentPerCustomer <- count(agentsFkCustomer, vars="fkCustomer.Depositor_Mobile")
realFickleCustomerID <- numOfAgentPerCustomer[which(numOfAgentPerCustomer$freq>1),]
realFickleCustomer <- fkCustomer[which(fkCustomer$Depositor_Mobile %in% realFickleCustomerID$fkCustomer.Depositor_Mobile),]
realFickleCustomer$numOfSwitch <- lookup(realFickleCustomer$Depositor_Mobile, realFickleCustomerID)

#combine rpCustomer and realFickleCustomer
str(rpCustomer)
str(realFickleCustomer)
traindata <- rbind(rpCustomer, realFickleCustomer)
write.csv(traindata, "Dec2014_SBI_Repeat_Customer_Pattern_by_Sender.csv", row.names=FALSE)
verifywriteOutput = read.csv("Dec2014_SBI_Repeat_Customer_Pattern_by_Sender.csv", header = TRUE)

# ===== for each CSP_Code, count the number of different Depositor_Mobile ======
#rpCustomer.csp_code.depositor_mb <- data.frame(rpCustomer$CSP_Code, rpCustomer$Depositor_Mobile)
#tbRpCs <- unique(rpCustomer.csp_code.depositor_mb)
#tbRpCSC <- count(tbRpCs, vars = "rpCustomer.CSP_Code")
#qplot(rpCustomer.CSP_Code, data=tbRpCs, geom="histogram")

# ===== Population of repeat customer by their repeat times ====
#rpDist <- count(rpCustomer, vars = "Depositor_Mobile")
#rpCountDist <- count(rpDist, vars = "freq")
#colnames(rpCountDist) <- c("RepeatTimes", "Count")
#qplot(RepeatTimes, Count, data=rpCountDist, geom = c("line","point"))


#test lookup funciton
#key <- data.frame(x=1:2, y=c("A", "B"))
#big.vec <- sample(1:2, 3000000, TRUE)
#out <- lookup(big.vec, key)
#out[1:20]
