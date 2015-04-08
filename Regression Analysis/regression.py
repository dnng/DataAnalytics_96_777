from numpy import *
from scipy import stats


def loadDataSet(fileName):
    numFeat = len(open(fileName).readline().split(',')) - 1 
    dataMat = []; labelMat = []
    fr = open(fileName)
    
    for line in fr.readlines():    
        lineArr =[]
        curLine = line.strip().split(',')
        
        for i in range(numFeat):
            lineArr.append(float(curLine[i]))
        
        dataMat.append(lineArr)
        labelMat.append(float(curLine[-1]))

    return dataMat, labelMat


def standRegression(xArr, yArr):
    xMat = mat(xArr)
    yMat = mat(yArr).T
    xTx = xMat.T * xMat

    #Check whether inverse matrix exists or not
    if linalg.det(xTx) == 0.0:
        print "This matrix is singular, cannot do inverse"
        ws = linalg.lstsq(xMat, yMat)[0]
        return ws
    ws = xTx.I * (xMat.T * yMat)
    return ws

# Calculate regression error
def rssError(yArr, yHatArr):

	return sqrt(average((absolute(yArr - yHatArr))**2))

# Locally weighted linear regression (with Gausian kernel)
def lwlr(testPoint, xArr, yArr, k = 1.0):
	xMat = mat(xArr)
	yMat = mat(yMat)
	m = shape(xMat)[0]
	weights = mat(eye((m)))   # Create diagonal matrix
	for j in range(m):
		diffMat = testPoint - xMat[j, :]
		weights[j, j] = exp(diffMat * diffMat.T / (-2.0*k**2))
	xTx = xMat.T * (weights * xMat)

	# Check whether inverse matrix exists or not
	if linalg.det(xTx) == 0.0:
		print "This matrix is singular, cannot do inverse"
		return
	ws = xTx.I * (xMat.T * (weights * yMat))
	return testPoint * ws


def lwlrTest(testArr, xArr, yArr, k = 1.0):
	m = shape(testArr)[0]
	yHat = zeros(m)
	for i in range(m):
		yHat[i] = lwlr(testArr[i], xArr, yArr, k)
	return yHat


# Ridge regression
def ridgeRegres(xMat,yMat,lam=0.2):
    xTx = xMat.T*xMat
    denom = xTx + eye(shape(xMat)[1])*lam
    
    if linalg.det(denom) == 0.0:
    	print "This matrix is singular, cannot do inverse"
    	return

    ws = denom.I * (xMat.T*yMat)
    return ws

def ridgeTest(xArr,yArr):
    xMat = mat(xArr); yMat=mat(yArr).T
    yMean = mean(yMat,0)
    yMat = yMat - yMean
    xMeans = mean(xMat,0)
    xVar = var(xMat,0)
    xMat = (xMat - xMeans)/xVar

    # Test 30 different lamda variables
    numTestPts = 30
    wMat = zeros((numTestPts,shape(xMat)[1]))
    for i in range(numTestPts):
        ws = ridgeRegres(xMat,yMat,exp(i-10))
        wMat[i,:]=ws.T
    return wMat


# 10-fold Cross Validation
def crossValidation(xArr,yArr,numVal=10):
    m = len(yArr)
    indexList = range(m)
    errorMat = zeros((numVal,30))
    
    for i in range(numVal):
        trainX=[]; trainY=[]
        testX = []; testY = []
        random.shuffle(indexList)
        for j in range(m):
            # 90% data for taining and 10% for testing
            if j < m*0.9:
                trainX.append(xArr[indexList[j]])
                trainY.append(yArr[indexList[j]])
            else:
                testX.append(xArr[indexList[j]])
                testY.append(yArr[indexList[j]])

        wMat = ridgeTest(trainX,trainY)
    
    	for k in range(30):
        	matTestX = mat(testX); matTrainX=mat(trainX)
        	meanTrain = mean(matTrainX,0)
        	varTrain = var(matTrainX,0)
        	matTestX = (matTestX-meanTrain)/varTrain
        	yEst = matTestX * mat(wMat[k,:]).T + mean(trainY)
        	errorMat[i,k]=rssError(yEst.T.A,array(testY))
    
    meanErrors = mean(errorMat,0)
    minMean = float(min(meanErrors))
    bestWeights = wMat[nonzero(meanErrors==minMean)]
    xMat = mat(xArr); yMat=mat(yArr).T
    meanX = mean(xMat,0); varX = var(xMat,0)
    unReg = bestWeights/varX
    print "min regression erreo is: " + str(minMean)
    print "the best model from Ridge Regression is:\n",unReg 
    print "with constant term: ",\
        -1*sum(multiply(meanX,unReg)) + mean(yMat)

    return unReg

def testCrossValidation(testArr, xArr, yArr, numVal=10):

    m = shape(testArr)[0]
    yHat = zeros(m)
    weights = crossValidation(xArr, yArr, 10)
    for i in range(m):
        yHat[i] = testArr[i] * weights.T
    return yHat




