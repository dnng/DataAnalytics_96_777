setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
input_filename <- "DecD2C_2014.csv"
output_filename <- "DecD2C_2014_CSP_Circle_List.csv"
txdata = read.csv(input_filename, header = TRUE)
#"JanD2C_2015.csv"
#"FebD2C_2015.csv"
str(txdata)
CSP_Code <- data.frame(unique(txdata$CSP_Code))
CSP_CircleList <- data.frame(unique(txdata$CSP_Circle))
CSP_NameList <- data.frame(unique(txdata$CSP_Name))
SCSP_NameList <- data.frame(unique(txdata$SCSP_Name))
SCSP_CodeList <- data.frame(unique(txdata$SCSP_Code))

write.csv(CSP_Code, "DecD2C_2014_CSP_Code_List.csv", row.names=FALSE)
write.csv(CSP_CircleList, "DecD2C_2014_CSP_Circle_List.csv", row.names=FALSE)
write.csv(CSP_NameList, "DecD2C_2014_CSP_NameList.csv", row.names=FALSE)
write.csv(SCSP_NameList, "DecD2C_2014_SCSP_NameList.csv", row.names=FALSE)
write.csv(SCSP_CodeList, "DecD2C_2014_SCSP_CodeList.csv", row.names=FALSE)

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
