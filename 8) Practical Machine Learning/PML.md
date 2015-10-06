---
title: "Practical Machine Learning Project (Coursera) - Quantified Data Analysis"
author: "Mehul Patel"
date: "September 27, 2015"
output: html_document
---

Introduction
------------

Using devices such as Jawbone Up, Nike FuelBand, and Fitbit it is now possible to collect a large amount of data about personal activity relatively inexpensively. These type of devices are part of the quantified self movement – a group of enthusiasts who take measurements about themselves regularly to improve their health, to find patterns in their behavior, or because they are tech geeks. One thing that people regularly do is quantify how much of a particular activity they do, but they rarely quantify how well they do it.  

In this project, we will use data from accelerometers on the belt, forearm, arm, and dumbell of 6 participants to predict the manner in which they did the exercise.

Data Preprocessing
------------------


```r
library(caret)
library(rpart)
library(rpart.plot)
library(randomForest)
library(corrplot)
```

Download the Data
-----------------


```r
trainingURL <-"https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
testingURL <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
trainingFile <- "./data/pml-training.csv"
testingFile  <- "./data/pml-testing.csv"
if (!file.exists("./data")) {
  dir.create("./data")
}
if (!file.exists(trainingFile)) {
  download.file(trainingURL, destfile=trainingFile, method="curl")
}
if (!file.exists(testingFile)) {
  download.file(testingURL, destfile=testingFile, method="curl")
}
```

Read the Data
-------------

After downloading the data from the data source, we can read the two csv files into two data frames.  

```r
trainRaw <- read.csv("./data/pml-training.csv")
testRaw <- read.csv("./data/pml-testing.csv")
dim(trainRaw)
```

```
## [1] 19622   160
```

```r
dim(testRaw)
```

```
## [1]  20 160
```

The training data set contains 19622 observations and 160 variables, while the testing data set contains 20 observations and 160 variables. The “classe” variable in the training set is the outcome to predict.  

Clean the Data
--------------

In this step, we will clean the data and get rid of observations with missing values as well as some meaningless variables.  


```r
sum(complete.cases(trainRaw))
```

```
## [1] 406
```

First, we remove columns that contain NA missing values.  


```r
trainRaw <- trainRaw[, colSums(is.na(trainRaw)) == 0] 
testRaw <- testRaw[, colSums(is.na(testRaw)) == 0] 
```

Next, we get rid of some columns that do not contribute much to the accelerometer measurements.  


```r
classe <- trainRaw$classe
trainRemove <- grepl("^X|timestamp|window", names(trainRaw))
trainRaw <- trainRaw[, !trainRemove]
trainCleaned <- trainRaw[, sapply(trainRaw, is.numeric)]
trainCleaned$classe <- classe
testRemove <- grepl("^X|timestamp|window", names(testRaw))
testRaw <- testRaw[, !testRemove]
testCleaned <- testRaw[, sapply(testRaw, is.numeric)]
```

Now, the cleaned training data set contains 19622 observations and 53 variables, while the testing data set contains 20 observations and 53 variables. The “classe” variable is still in the cleaned training set.  

Slice the Data
--------------

Then, we can split the cleaned training set into a pure training data set (70%) and a validation data set (30%). We will use the validation data set to conduct cross validation in future steps.  


```r
set.seed(2108) # For reproducibile purpose
inTrain <- createDataPartition(trainCleaned$classe, p=0.70, list=F)
trainData <- trainCleaned[inTrain, ]
testData <- trainCleaned[-inTrain, ]
```

Data Modeling
-------------

We fit a predictive model for activity recognition using Random Forest algorithm because it automatically selects important variables and is robust to correlated covariates & outliers in general. We will use 5-fold cross validation when applying the algorithm.  


```r
controlRf <- trainControl(method="cv", 5)
modelRf <- train(classe ~ ., data=trainData, method="rf", trControl=controlRf, ntree=250)
modelRf
```

```
## Random Forest 
## 
## 13737 samples
##    52 predictor
##     5 classes: 'A', 'B', 'C', 'D', 'E' 
## 
## No pre-processing
## Resampling: Cross-Validated (5 fold) 
## Summary of sample sizes: 10990, 10990, 10989, 10990, 10989 
## Resampling results across tuning parameters:
## 
##   mtry  Accuracy   Kappa      Accuracy SD  Kappa SD   
##    2    0.9903907  0.9878440  0.002209074  0.002794195
##   27    0.9917740  0.9895942  0.001953913  0.002471646
##   52    0.9860958  0.9824122  0.003028868  0.003829583
## 
## Accuracy was used to select the optimal model using  the largest value.
## The final value used for the model was mtry = 27.
```

Then, we estimate the performance of the model on the validation data set.  


```r
predictRf <- predict(modelRf, testData)
confusionMatrix(testData$classe, predictRf)
```

```
## Confusion Matrix and Statistics
## 
##           Reference
## Prediction    A    B    C    D    E
##          A 1672    2    0    0    0
##          B   13 1124    2    0    0
##          C    0    5 1018    3    0
##          D    0    1   10  951    2
##          E    0    2    3    4 1073
## 
## Overall Statistics
##                                           
##                Accuracy : 0.992           
##                  95% CI : (0.9894, 0.9941)
##     No Information Rate : 0.2863          
##     P-Value [Acc > NIR] : < 2.2e-16       
##                                           
##                   Kappa : 0.9899          
##  Mcnemar's Test P-Value : NA              
## 
## Statistics by Class:
## 
##                      Class: A Class: B Class: C Class: D Class: E
## Sensitivity            0.9923   0.9912   0.9855   0.9927   0.9981
## Specificity            0.9995   0.9968   0.9984   0.9974   0.9981
## Pos Pred Value         0.9988   0.9868   0.9922   0.9865   0.9917
## Neg Pred Value         0.9969   0.9979   0.9969   0.9986   0.9996
## Prevalence             0.2863   0.1927   0.1755   0.1628   0.1827
## Detection Rate         0.2841   0.1910   0.1730   0.1616   0.1823
## Detection Prevalence   0.2845   0.1935   0.1743   0.1638   0.1839
## Balanced Accuracy      0.9959   0.9940   0.9919   0.9950   0.9981
```

```r
accuracy <- postResample(predictRf, testData$classe)
accuracy
```

```
##  Accuracy     Kappa 
## 0.9920136 0.9898958
```

```r
oose <- 1 - as.numeric(confusionMatrix(testData$classe, predictRf)$overall[1])
oose
```

```
## [1] 0.007986406
```

So, the estimated accuracy of the model is 99.20% and the estimated out-of-sample error is 0.79%.

Predicting for Test data-set
----------------------------

Now, we apply the model to the original testing data set downloaded from the data source. We remove the problem_id column first.  


```r
result <- predict(modelRf, testCleaned[, -length(names(testCleaned))])
result
```

```
##  [1] B A B A A E D B A A B C B A E E A B B B
## Levels: A B C D E
```

Appendix
--------

1. Correlation Matrix Visualization  


```r
corrPlot <- cor(trainData[, -length(names(trainData))])
corrplot(corrPlot, method="color")
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png) 

2. Tree Visualization  


```r
treeModel <- rpart(classe ~ ., data=trainData, method="class")
prp(treeModel) # fast plot
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png) 
