import sys
import regression
from numpy import *

def parseData(filePath):

	dataMat = []
	fd = open(filePath, 'r')
	line = fd.readline()
	line = line.strip().split('\r')

	for i in range(len(line)):
		tmpLine = line[i].strip().split(',')

		# Parse header
		if i == 0:
			headerLine = tmpLine
		else:
			dataMat.append(tmpLine)
	fd.close()

	return dataMat

def constructFeature(dataArr):

	xArr = []
	yArr = []
	for i in range(len(dataArr)):
		timeData = dataArr[i][0]
		timeData = timeData.strip().split()
		hour = timeData[1].split(':')[0]

		scspCode = dataArr[i][1]
		cspCode = dataArr[i][6]

		source = dataArr[i][10]
		sourceCode = 0
		if(source == "ussd" or source == "idea_ussd"):
			sourceCode = 1
		elif(source == "EDIC" or source == "CONNECT"):
			sourceCode = 2
		elif(source == "app_eko_v3.33"):
			sourceCode = 3
		else:
			sourceCode = 4

		label = dataArr[i][9]

		try:
			xArr.append([int(hour), int(scspCode), int(cspCode), sourceCode])
			yArr.append(int(label))
		except ValueError:
			continue

	return xArr, yArr


# Normalizie data set
def normalizeData(xArr, yArr):
	
	xMat = mat(xArr)
	yMat = mat(yArr)

	meanX = mean(xMat, 0)
	meanY = mean(yMat, 1)
	stdX = std(xMat, 0)
	stdY = std(yMat, 1)
	xMat = (xMat - meanX) / stdX
	yMat = (yMat - meanY) / stdY

	dataMat = concatenate((xMat, yMat.T), axis=1)

	#savetxt(dataFileName, dataMat, delimiter=",")

	return dataMat


# Divide data into traing and testing group
def divideData(fileName):
	xArr, yArr = regression.loadDataSet(fileName)

	m = len(yArr)
	trainX = [] ; trainY = []
	testX = [] ; testY = []

	for i in range(m):
		if i < m * 0.9:
			trainX.append(xArr[i])
			trainY.append(yArr[i])
		else:
			testX.append(xArr[i])
			testY.append(yArr[i])

	xMatTrain = mat(trainX) ; yMatTrain = mat(trainY)
	xMatTest = mat(testX) ; yMatTest = mat(testY)


	trainMat = concatenate((xMatTrain, yMatTrain.T), axis=1)
	testMat = concatenate((xMatTest, yMatTest.T), axis=1)

	savetxt("trainingDataSet.csv", trainMat, delimiter = ",")
	savetxt("testingDataSet.csv", testMat, delimiter = ",")



def sortCustermer(dataArr, columnNum):
	sortedByCustomer = sorted(dataArr, key=lambda tup: tup[columnNum])
	return sortedByCustomer







