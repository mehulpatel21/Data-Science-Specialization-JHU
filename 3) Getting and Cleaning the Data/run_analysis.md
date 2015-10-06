Instructions for project
------------------------

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.  
> 
> One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
> 
> http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
> 
> Here are the data for the project: 
> 
> https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
> 
> You should create one R script called run_analysis.R that does the following. 
> 
> 1. **DONE** Merges the training and the test sets to create one data set.
> 2. **DONE** Extracts only the measurements on the mean and standard deviation for each measurement.
> 3. **DONE** Uses descriptive activity names to name the activities in the data set.
> 4. **DONE** Appropriately labels the data set with descriptive activity names.
> 5. **DONE** Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
> 
> Good luck!



Preliminaries
-------------

Load packages.


```r
packages <- c("data.table", "reshape2")
sapply(packages, require, character.only = TRUE, quietly = TRUE)
```

```
## data.table   reshape2 
##       TRUE       TRUE
```


Set path.


```r
path <- getwd()
path
```

```
## [1] "/Users/Leo/Documents/Repositories/Coursera/GettingAndCleaningData/Project"
```



Get the data
------------

Download the file. Put it in the `Data` folder.


```r
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
if (!file.exists(path)) {
    dir.create(path)
}
download.file(url, file.path(path, f))
```


The archive put the files in a folder named `UCI HAR Dataset`. Set this folder as the input path. List the files here.


```r
pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive = TRUE)
```

```
##  [1] "activity_labels.txt"                         
##  [2] "features.txt"                                
##  [3] "features_info.txt"                           
##  [4] "README.txt"                                  
##  [5] "test/Inertial Signals/body_acc_x_test.txt"   
##  [6] "test/Inertial Signals/body_acc_y_test.txt"   
##  [7] "test/Inertial Signals/body_acc_z_test.txt"   
##  [8] "test/Inertial Signals/body_gyro_x_test.txt"  
##  [9] "test/Inertial Signals/body_gyro_y_test.txt"  
## [10] "test/Inertial Signals/body_gyro_z_test.txt"  
## [11] "test/Inertial Signals/total_acc_x_test.txt"  
## [12] "test/Inertial Signals/total_acc_y_test.txt"  
## [13] "test/Inertial Signals/total_acc_z_test.txt"  
## [14] "test/subject_test.txt"                       
## [15] "test/X_test.txt"                             
## [16] "test/y_test.txt"                             
## [17] "train/Inertial Signals/body_acc_x_train.txt" 
## [18] "train/Inertial Signals/body_acc_y_train.txt" 
## [19] "train/Inertial Signals/body_acc_z_train.txt" 
## [20] "train/Inertial Signals/body_gyro_x_train.txt"
## [21] "train/Inertial Signals/body_gyro_y_train.txt"
## [22] "train/Inertial Signals/body_gyro_z_train.txt"
## [23] "train/Inertial Signals/total_acc_x_train.txt"
## [24] "train/Inertial Signals/total_acc_y_train.txt"
## [25] "train/Inertial Signals/total_acc_z_train.txt"
## [26] "train/subject_train.txt"                     
## [27] "train/X_train.txt"                           
## [28] "train/y_train.txt"
```


**See the `README.txt` file in /Users/Leo/Documents/Repositories/Coursera/GettingAndCleaningData/Project for detailed information on the dataset.**

For the purposes of this project, the files in the `Inertial Signals` folders are not used.


Read the files
--------------

Read the subject files.


```r
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(pathIn, "test", "subject_test.txt"))
```


Read the activity files. For some reason, these are called *label* files in the `README.txt` documentation.


```r
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(pathIn, "test", "Y_test.txt"))
```


Read the data files. `fread` seems to be giving me some trouble reading files. Using a helper function, read the file with `read.table` instead, then convert the resulting data frame to a data table. Return the data table.


```r
fileToDataTable <- function(f) {
    df <- read.table(f)
    dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(pathIn, "train", "X_train.txt"))
dtTest <- fileToDataTable(file.path(pathIn, "test", "X_test.txt"))
```



Merge the training and the test sets
------------------------------------

Concatenate the data tables.


```r
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
```


Merge columns.


```r
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
```


Set key.


```r
setkey(dt, subject, activityNum)
```



Extract only the mean and standard deviation
--------------------------------------------

Read the `features.txt` file. This tells which variables in `dt` are measurements for the mean and standard deviation.


```r
dtFeatures <- fread(file.path(pathIn, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
```


Subset only measurements for the mean and standard deviation.


```r
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
```


Convert the column numbers to a vector of variable names matching columns in `dt`.


```r
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
head(dtFeatures)
```

```
##    featureNum       featureName featureCode
## 1:          1 tBodyAcc-mean()-X          V1
## 2:          2 tBodyAcc-mean()-Y          V2
## 3:          3 tBodyAcc-mean()-Z          V3
## 4:          4  tBodyAcc-std()-X          V4
## 5:          5  tBodyAcc-std()-Y          V5
## 6:          6  tBodyAcc-std()-Z          V6
```

```r
dtFeatures$featureCode
```

```
##  [1] "V1"   "V2"   "V3"   "V4"   "V5"   "V6"   "V41"  "V42"  "V43"  "V44" 
## [11] "V45"  "V46"  "V81"  "V82"  "V83"  "V84"  "V85"  "V86"  "V121" "V122"
## [21] "V123" "V124" "V125" "V126" "V161" "V162" "V163" "V164" "V165" "V166"
## [31] "V201" "V202" "V214" "V215" "V227" "V228" "V240" "V241" "V253" "V254"
## [41] "V266" "V267" "V268" "V269" "V270" "V271" "V345" "V346" "V347" "V348"
## [51] "V349" "V350" "V424" "V425" "V426" "V427" "V428" "V429" "V503" "V504"
## [61] "V516" "V517" "V529" "V530" "V542" "V543"
```


Subset these variables using variable names.


```r
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]
```



Use descriptive activity names
------------------------------

Read `activity_labels.txt` file. This will be used to add descriptive names to the activities.


```r
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))
```



Label with descriptive activity names
-----------------------------------------------------------------

Merge activity labels.


```r
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)
```


Add `activityName` as a key.


```r
setkey(dt, subject, activityNum, activityName)
```


Melt the data table to reshape it from a short and wide format to a tall and narrow format.


```r
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))
```


Merge activity name.


```r
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
    all.x = TRUE)
```


Create a new variable, `activity` that is equivalent to `activityName` as a factor class.
Create a new variable, `feature` that is equivalent to `featureName` as a factor class.


```r
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)
```


Seperate features from `featureName` using the helper function `grepthis`.


```r
grepthis <- function(regex) {
    grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))
```


Check to make sure all possible combinations of `feature` are accounted for by all possible combinations of the factor class variables.


```r
r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", 
    "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2
```

```
## [1] TRUE
```


Yes, I accounted for all possible combinations. `feature` is now redundant.



Create a tidy data set
----------------------

Create a data set with the average of each variable for each activity and each subject.


```r
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, 
    featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]
```


Make codebook.


```r
knit("makeCodebook.Rmd", output = "codebook.md", encoding = "ISO8859-1", quiet = TRUE)
```

```
## [1] "codebook.md"
```

```r
markdownToHTML("codebook.md", "codebook.html")
```

