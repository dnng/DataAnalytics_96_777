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

output_filename <- "All_SBI_Repeat_Customer_Pattern_by_Sender.csv"

txdata$CSP_Code <- as.factor(txdata$CSP_Code)

# ===== get repeat customer =====
# ===== get repeat customer (customer who has multiple transaction data)  ====
rpCustomer <- txdata[which(duplicated(txdata$Depositor_Mobile)),]
rpCustomer <- txdata[which(txdata$Depositor_Mobile %in% rpCustomer$Depositor_Mobile),]
rpCustomer <- rpCustomer[order(rpCustomer$Depositor_Mobile, rpCustomer$Tx_Time),]
txAna <- c(round((nrow(txdata)-nrow(rpCustomer))/nrow(txdata)*100, 2), round(nrow(rpCustomer)/nrow(txdata)*100,2))
txCount <- c((nrow(txdata)-nrow(rpCustomer)), nrow(rpCustomer))
lbls <- c(paste("From One-time Customer\n",txCount[1],",", txAna[1],"%"), paste("From Repeat Customer\n", txCount[2] ,",", txAna[2],"%"))
pie(txAna, labels=lbls, main="Transaction Source")
# ===== get transaction data with the same customer ID, but different CSP_Code  ==== 
agentsrpCustomer <- data.frame(rpCustomer$CSP_Code, rpCustomer$Depositor_Mobile)
# ===== get list of unique (customerID, Agent ID) pair ====
agentsrpCustomer <- unique(agentsrpCustomer)
# ===== count the number of agents per customer ID ====
numOfAgentPerCustomer <- count(agentsrpCustomer, vars="rpCustomer.Depositor_Mobile")

# ===== plot the histogram of # of agents per customer ====
ggplot(numOfAgentPerCustomer, aes(numOfAgentPerCustomer$freq)) + 
  geom_histogram(binwidth = 1, aes(fill=..count..)) +
  xlab("# of Agents") +
  ylab("# of Customers")

# ===== plot the pie chart of loyal customers vs. fickle customers ====
numOfAgPerCus_gt_1 <- numOfAgentPerCustomer[which(numOfAgentPerCustomer$freq>1),]
numOfFickleCustomer <- nrow(numOfAgPerCus_gt_1)
numOfLoyalCustomer <- nrow(numOfAgentPerCustomer) - numOfFickleCustomer
pctOfFickleCustomer <- round(numOfFickleCustomer/(numOfFickleCustomer+numOfLoyalCustomer)*100, 2)
pctOfLoyalCustomer <- round(numOfLoyalCustomer/(numOfFickleCustomer+numOfLoyalCustomer)*100, 2)
lbls <- c(paste("Loyal Customer\n",numOfLoyalCustomer,",", pctOfLoyalCustomer,"%"),
          paste("Fickle Customer\n", numOfFickleCustomer ,",", pctOfFickleCustomer,"%"))
pie(c(numOfLoyalCustomer, numOfFickleCustomer), labels=lbls, main="Customers", col=topo.colors(2))

# ==== get the table of the histrogram of # of agents per customer ====
custTableGlance <- data.frame(table(numOfAgentPerCustomer$freq))
colnames(custTableGlance) <- c('# of Agents', 'Customer Count')

# ==== note number of agents information on every transaction record =====
rpCustomer$numOfSwitch <- lookup(rpCustomer$Depositor_Mobile, numOfAgentPerCustomer)

# ==== plot pie chart for transactions made by fickle/loyal customers ====
numOfTxByFickleCustomer <- nrow(rpCustomer[which(rpCustomer$numOfSwitch>1),])
numOfTxByLoyalCustomer <- nrow(rpCustomer[which(rpCustomer$numOfSwitch==1),])
pctOfTxByFickCustomer <- round(numOfTxByFickleCustomer/nrow(rpCustomer)*100, 2)
pctOfTxByLoyalCustomer <- round(numOfTxByLoyalCustomer/nrow(rpCustomer)*100, 2)
lbls <- c(paste("By Loyal Customer\n",numOfTxByLoyalCustomer,",", pctOfTxByLoyalCustomer,"%"),
          paste("By Fickle Customer\n", numOfTxByFickleCustomer , ",", pctOfTxByFickCustomer,"%"))

pie(c(numOfTxByLoyalCustomer, numOfTxByFickleCustomer), labels=lbls, main="Transaction Source", col=c("green","yellow"))
rpCustomer$Tx_Time <- convertToDateTime(rpCustomer$Tx_Time)

#write.csv(rpCustomer, output_filename, row.names=FALSE)

#txdata for agents who are switched
txdataAgentSwitched <- rpCustomer[which(rpCustomer$numOfSwitch>1),]
#NthAgent ===> Nth agent for the same customer.
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
txdataAgentSwitchedDemo <- txdataAgentSwitched[,c("Tx_Time", "CSP_Code", "Depositor_Mobile", "switchMove", "NthAgent")]
txDatSwFactor <- data.frame(lapply(txdataAgentSwitched, factor))

#===== collect feature list =====
CSP_Code <- data.frame(unique(txdata$CSP_Code))
CSP_CircleList <- data.frame(unique(txdata$CSP_Circle))
CSP_NameList <- data.frame(unique(txdata$CSP_Name))
SCSP_NameList <- data.frame(unique(txdata$SCSP_Name))
SCSP_CodeList <- data.frame(unique(txdata$SCSP_Code))
CustomerID <- data.frame(unique(txdata$Depositor_Mobile))

#Try SCSP_Code
ggplot(txDatSwFactor, aes(x=SCSP_Code,fill=switchMove)) + geom_histogram()

#Try CSP_Circle
ggplot(txDatSwFactor, aes(x=CSP_Circle,fill=switchMove)) + geom_histogram()

#Try Agent ID
numFirstAgent <- count(txDatSwFactor[which(txDatSwFactor$switchMove=="First"),], vars="CSP_Code")
numSameAgent <- count(txDatSwFactor[which(txDatSwFactor$switchMove=="The Same"),], vars="CSP_Code")
numSwitchAgent <- count(txDatSwFactor[which(txDatSwFactor$switchMove=="Switch"),], vars="CSP_Code")
numGoBackAgent <- count(txDatSwFactor[which(txDatSwFactor$switchMove=="Go Back"),], vars="CSP_Code")

CSP_Code$num1stAgent <- lookup(CSP_Code[,1], numFirstAgent)
CSP_Code$numSameAgent <- lookup(CSP_Code[,1], numSameAgent)
CSP_Code$numSwitchAgent <- lookup(CSP_Code[,1], numSwitchAgent)
CSP_Code$numGoBackAgent <- lookup(CSP_Code[,1], numGoBackAgent)

CSP_Code[is.na(CSP_Code)] <- 0
CSP_Code$total <- rowSums(CSP_Code[,2:5])
CSP_Code <- CSP_Code[which(CSP_Code$total!=0),]

CSP_Code[,2:5] <- CSP_Code[,2:5]/CSP_Code[,ncol(CSP_Code)]

CSP_Code <- CSP_Code[order(CSP_Code$num1stAgent),]
barplot(t(CSP_Code[,2:5]),col=rainbow(7), xlab="Agent ID", ylab="Tx Type (%)", axisnames = F)

CSP_Code <- CSP_Code[order(CSP_Code$num1stAgent),]
barplot(CSP_Code$num1stAgent,col="Red", xlab="Agent ID", ylab="Tx Type (%)", axisnames = F)

CSP_Code <- CSP_Code[order(CSP_Code$numSameAgent),]
barplot(CSP_Code$numSameAgent,col="Yellow", xlab="Agent ID", ylab="Tx Type (%)", axisnames = F)

CSP_Code <- CSP_Code[order(CSP_Code$numSwitchAgent),]
barplot(CSP_Code$numSwitchAgent,col="Green", xlab="Agent ID", ylab="Tx Type (%)", axisnames = F)

CSP_Code <- CSP_Code[order(CSP_Code$numGoBackAgent),]
barplot(CSP_Code$numGoBackAgent,col="Cyan", xlab="Agent ID", ylab="Tx Type (%)", axisnames = F)

plot(c(1))
legend(1,1, c("First","Same","Switch","Go Back"),fill=rainbow(7))

#Try Amount
txDatSwFactor$AmountGroup <- trunc(as.numeric(as.character(txDatSwFactor$Amount))/1000) * 1000
ggplot(txDatSwFactor, aes(AmountGroup, fill=switchMove)) + geom_histogram()

#Try Source
ggplot(txDatSwFactor, aes(Source, fill=switchMove)) + geom_histogram()

#Try Fee
txDatSwFactor$FeeRate <- round(as.numeric(as.character(txDatSwFactor$Transaction.fee))/as.numeric(as.character(txDatSwFactor$Amount)), 2)
ggplot(txDatSwFactor, aes(FeeRate, fill=switchMove)) + geom_histogram()

#Try Com Rate
txDatSwFactor$ComRate <- round(1-as.numeric(as.character(txDatSwFactor$Income))/as.numeric(as.character(txDatSwFactor$Transaction.fee)), 2)
ggplot(txDatSwFactor, aes(ComRate, fill=switchMove)) + geom_histogram()

#### ======TODO====== Analyze by time stampt =========
strftime(txDatSwFactor$Tx_Time, format="%H")
txDatSwFactor$Hour <- strftime(txDatSwFactor$Tx_Time, "%H")
ggplot(txDatSwFactor, aes(Hour, fill=switchMove)) + geom_histogram() + xlab("Hours")
txDatSwFactor$Month <- strftime(txDatSwFactor$Tx_Time, "%m")
ggplot(txDatSwFactor, aes(Month, fill=switchMove)) + geom_histogram() + xlab("Months")
txDatSwFactor$Day <- strftime(txDatSwFactor$Tx_Time, "%d")
ggplot(txDatSwFactor, aes(Day, fill=switchMove)) + geom_histogram() + xlab("Days")
txDatSwFactor$Day <- strftime(txDatSwFactor$Tx_Time, "%u")
ggplot(txDatSwFactor, aes(Day, fill=switchMove)) + geom_histogram() + xlab("Week Days") 


txDatSwFactor <- data.frame(lapply(txDatSwFactor, factor))

rules.all <- apriori(txDatSwFactor[,!(colnames(txDatSwFactor) %in% c("Month", "NthAgent", "numOfSwitch"))], 
                     parameter = list(supp=0.2, conf=0.2),
                     appearance=list(default="lhs",
                                     rhs=c("switchMove=First", "switchMove=The Same", 
                                           "switchMove=Go Back","switchMove=Switch")))
rules.sorted <- sort(rules.all, by="confidence")
inspect(rules.sorted)
plot(rules.all, method="graph")
plot(rules.all, method="graph", control = list(type="items"))
plot(rules.all, method="paracoord", control = list(reorder="true"))
 
