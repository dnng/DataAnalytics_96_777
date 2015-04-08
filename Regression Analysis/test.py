import sys
from numpy import *
import parseData
import regression
import matplotlib.pyplot as plt


# Data Pre-processing
#filePath1 = "/Users/chih-fenglin/Box Sync/Box Sync/CMU Course/Data Analytics/Project/Data/December.csv"
#filePath2 = "/Users/chih-fenglin/Box Sync/Box Sync/CMU Course/Data Analytics/Project/Data/Jan.csv"

#dataArr1 = parseData.parseData(filePath1)
#dataArr2 = parseData.parseData(filePath2)


#xArr1, yArr1 = parseData.constructFeature(dataArr1)
#xArr2, yArr2 = parseData.constructFeature(dataArr2)
#dataMat1 = parseData.normalizeData(xArr1, yArr1)
#dataMat2 = parseData.normalizeData(xArr2, yArr2)

#dataMat = concatenate((dataMat1, dataMat2), axis=0)
#savetxt("normalizeData.csv", dataMat, delimiter=",")
#parseData.divideData("normalizeData.csv")



# Regression Analysis
xArr_train, yArr_train = regression.loadDataSet("trainingDataSet.csv")
xArr_test, yArr_test = regression.loadDataSet("testingDataSet.csv")

ws = regression.standRegression(xArr_train, yArr_train)

xMat_test = mat(xArr_test)
yMat_test = mat(yArr_test)
yHat_test = xMat_test * ws

#xMat_train = mat(xArr_train)
#yMat_train = mat(yArr_train)
#yHat_train = xMat_train * ws


fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(range(len(yArr_test)), yMat_test.T[:, 0].flatten().A[0], 'b-', label = 'Original Data')
ax.plot(range(len(yArr_test)), yHat_test[:, 0].flatten().A[0], 'r-', label = 'Predict Data')
ax.legend()
plt.ylabel("Total Money Amount (Normalized)")
plt.xlabel("Transactions")
plt.show()
