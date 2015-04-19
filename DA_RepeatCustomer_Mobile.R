setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
input_filename <- "JanD2C_2015.csv"
output_filename <- "JanD2C_2015_SBI_Repeat_Customer_Pattern_by_Sender.csv"
txdata = read.csv(input_filename, header = TRUE)
#"JanD2C_2015.csv"
#"FebD2C_2015.csv"
str(txdata)
txdata$CSP_Code <- as.factor(txdata$CSP_Code)
txdata$SBI_Account <- as.factor(txdata$SBI_Account)
str(txdata)
summary(txdata)

# ===== get repeat customer =====
#   ===== get repeat customer (customer who has multiple transaction data)  ====
fkCustomer <- txdata[which(duplicated(txdata$Depositor_Mobile)),]
fkCustomer <- txdata[which(txdata$Depositor_Mobile %in% fkCustomer$Depositor_Mobile),]
fkCustomer <- fkCustomer[order(fkCustomer$Depositor_Mobile),]
#   ===== get transaction data with the same customer ID, but different CSP_Code  ==== 
agentsFkCustomer <- data.frame(fkCustomer$CSP_Code, fkCustomer$Depositor_Mobile)
agentsFkCustomer <- unique(agentsFkCustomer)
numOfAgentPerCustomer <- count(agentsFkCustomer, vars="fkCustomer.Depositor_Mobile")
#realFickleCustomerID <- numOfAgentPerCustomer[which(numOfAgentPerCustomer$freq>1),]
#realFickleCustomer <- fkCustomer[which(fkCustomer$Depositor_Mobile %in% realFickleCustomerID$fkCustomer.Depositor_Mobile),]
fkCustomer$numOfSwitch <- lookup(fkCustomer$Depositor_Mobile, numOfAgentPerCustomer)
table(fkCustomer$numOfSwitch)
#combine rpCustomer and realFickleCustomer
write.csv(fkCustomer, output_filename, row.names=FALSE)
verifywriteOutput = read.csv(output_filename, header = TRUE)

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
