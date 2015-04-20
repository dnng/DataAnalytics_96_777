setwd("~/Google Drive/DataAnalytics/Transaction Data (updated)/SBI")
library("plyr", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("qdapTools", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")
library("openxlsx", lib.loc="/Library/Frameworks/R.framework/Versions/3.1/Resources/library")

input_filename <- "DecD2C_2014.xlsx"
#"JanD2C_2015.csv"
#"FebD2C_2015.csv"
txdata <- read.xlsx(input_filename, 1)  # read first sheet

txdata$Tx_Time <- convertToDateTime(txdata$Tx_Time)

output_filename <- "DecD2C_2014_SBI_Repeat_Customer_Pattern_by_Sender.csv"
str(txdata)
txdata$CSP_Code <- as.factor(txdata$CSP_Code)
txdata$SBI_Account <- as.factor(txdata$SBI_Account)
str(txdata)
summary(txdata)

# ===== get repeat customer =====
#   ===== get repeat customer (customer who has multiple transaction data)  ====
fkCustomer <- txdata[which(duplicated(txdata$Depositor_Mobile)),]
fkCustomer <- txdata[which(txdata$Depositor_Mobile %in% fkCustomer$Depositor_Mobile),]
fkCustomer <- fkCustomer[order(fkCustomer$Depositor_Mobile, fkCustomer$Tx_Time),]
#   ===== get transaction data with the same customer ID, but different CSP_Code  ==== 
agentsFkCustomer <- data.frame(fkCustomer$CSP_Code, fkCustomer$Depositor_Mobile)
agentsFkCustomer <- unique(agentsFkCustomer)
numOfAgentPerCustomer <- count(agentsFkCustomer, vars="fkCustomer.Depositor_Mobile")
fkCustomer$numOfSwitch <- lookup(fkCustomer$Depositor_Mobile, numOfAgentPerCustomer)
table(fkCustomer$numOfSwitch)
#combine rpCustomer and realFickleCustomer
write.csv(fkCustomer, output_filename, row.names=FALSE)
verifywriteOutput = read.csv(output_filename, header = TRUE)

#txdata for agents who are switched
txdataAgentSwitched <- fkCustomer[which(fkCustomer$numOfSwitch>1),]
#NthAgent ===> Nth agent for the same customer.
#switchMove ===> 1: first. 2: switch, 0: the same, -1 go back
customerName <- 0
agentName <- 0
agentList <- data.frame(name="")
for(i in 1:nrow(txdataAgentSwitched)){
  if(txdataAgentSwitched[i,"Depositor_Mobile"]!=customerName){
    customerName <- txdataAgentSwitched[i, "Depositor_Mobile"]
    agentName <- txdataAgentSwitched[i, "CSP_Code"]
    agentList <- data.frame(name=agentName)
    txdataAgentSwitched[i, "switchMove"] <- "First"
    txdataAgentSwitched[i, "NthAgent"] <- 1
  }else{
    tmpAgentName <- txdataAgentSwitched[i, "CSP_Code"]
    if(tmpAgentName==agentName){
      txdataAgentSwitched[i, "switchMove"] <- "The Same"
      txdataAgentSwitched[i, "NthAgent"] <- which(agentList$name==tmpAgentName)
    }else{
      if((tmpAgentName %in% agentList$name)){
        txdataAgentSwitched[i, "switchMove"] <- "Go Back"
        txdataAgentSwitched[i, "NthAgent"] <- which(agentList$name==tmpAgentName)
      }
      else{
        txdataAgentSwitched[i, "switchMove"] <- "Switch"
        txdataAgentSwitched[i, "NthAgent"] <- nrow(agentList)+1
        agentList[nrow(agentList)+1, "name"] <- tmpAgentName
      }
      agentName <- tmpAgentName
    }
  }
}
txdataAgentSwitched$switchMove <- as.factor(txdataAgentSwitched$switchMove)
#agents who are switched from
#agents who are switched to 


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

