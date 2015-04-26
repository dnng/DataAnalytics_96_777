setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI/excel")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("openxlsx", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("arules", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("arulesViz", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("data.table", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

input_filename1 <- "DecD2C_2014.xlsx"
input_filename2 <- "JanD2C_2015.xlsx"
txdata1 <- read.xlsx(input_filename1, 1)  # read first sheet
txdata2 <- read.xlsx(input_filename2, 1)  # read first sheet

colnames(txdata1)
colnames(txdata2)[13] <- "Transaction.fee"
txdata3 <- txdata2[,(colnames(txdata2) %in% colnames(txdata1))]
txdata <- rbind(txdata1, txdata3)
rm(txdata1)
rm(txdata2)
rm(txdata3)

#txdata$Tx_Time <- convertToDateTime(txdata$Tx_Time)

txdata$CSP_Code <- as.factor(txdata$CSP_Code)

# ===== get repeat SBI_Account from the same Agent =====

# ========== get freq of combination ("CSP_Code", "SBI_Account")  and create feature of MoneyLauderyPotential
count_RpSBI_Agent <- count(txdata, vars=c("CSP_Code", "SBI_Account"))
count_RpSBI_Agent.sorted <- count_RpSBI_Agent[order(count_RpSBI_Agent$freq, decreasing = T),]
count_RpSBI_Agent.sorted$Agent_Account_CB <- paste(count_RpSBI_Agent.sorted$CSP_Code,count_RpSBI_Agent.sorted$SBI_Account)
count_RpSBI_Agent.table <- data.table(count_RpSBI_Agent.sorted)
setkey(count_RpSBI_Agent.table, "CSP_Code", "SBI_Account")
txdata$MoneyLauderyPotential <- count_RpSBI_Agent.table[J(txdata$CSP_Code, txdata$SBI_Account), freq]
txdata$Agent_Account_CB <- paste(txdata$CSP_Code, txdata$SBI_Account)
# ==== plot the number transaction on the same agent/customer they made 
largerThanNine <- count_RpSBI_Agent.sorted[which(count_RpSBI_Agent.sorted$freq>30),]
barplot(largerThanNine$freq, col="Cyan", xlab="Different Agent Customer Combination", ylab="# of Transaction", axisnames = F)
# ==== MoneyLauderyPotential Leader
MnLauderyPotentialLeader <- txdata[which(txdata$MoneyLauderyPotential>=80),]
MnLauderyPotentialLeader <- MnLauderyPotentialLeader[order(MnLauderyPotentialLeader$MoneyLauderyPotential, decreasing = T),]
MnLauderyPotentialLeader$Tx_Time <- convertToDateTime(MnLauderyPotentialLeader$Tx_Time)
MnLauderyPotentialLeader$WeekDay <- strftime(MnLauderyPotentialLeader$Tx_Time, format="%u")
MnLauderyPotentialLeader$YearWeek <- strftime(MnLauderyPotentialLeader$Tx_Time, format="%y-%U")
MnLauderyPotentialLeader$MoneyLauderyPotential <- as.factor(MnLauderyPotentialLeader$MoneyLauderyPotential)
ggplot(MnLauderyPotentialLeader, aes(x=YearWeek, y=Amount, fill=WeekDay)) + geom_bar(stat= "identity") + facet_grid(. ~ MoneyLauderyPotential)
  