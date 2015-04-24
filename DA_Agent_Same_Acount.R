setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI/excel")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("openxlsx", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("arules", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("arulesViz", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

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

# ========== get freq of combination ("CSP_Code", "SBI_Account") 
count_RpSBI_Agent <- count(txdata, vars=c("CSP_Code", "SBI_Account"))
count_RpSBI_Agent.sorted <- count_RpSBI_Agent[order(count_RpSBI_Agent$freq, decreasing = T),]
setkey(count_RpSBI_Agent.sorted, )
#txdata$AgentRpSBI_Count <- lookup(txdata$)

