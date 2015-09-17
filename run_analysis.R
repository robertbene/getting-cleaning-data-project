require(plyr)

## Clean up workspace
rm(list=ls())

## Constant variables
file <- "dataset.zip"
dir <- "UCI HAR Dataset"
remoteUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
featureFilter <- ".*mean.*|.*std.*"

## Download the remote dataset if not exists in local file system
if(!file.exists(file)) {
    download.file(remoteUrl, file, method = "curl")
}

## unzip the dataset if required
if(!dir.exists(dir) && file.exists(file)) {
    unzip(zipfile = file)
}

## Load activity names
activityNames <- read.table(file = paste(dir, "activity_labels.txt", sep="/"))

## Load feature info
features <- read.table(file = paste(dir, "features.txt", sep="/"))

## Extract only the mean and standard deviation
featuresWanted <- grep(featureFilter, features[,2])

## Get and clean feature names
featuresNames <- features[featuresWanted,2]
featuresNames <- gsub('-mean', 'Mean', featuresNames)
featuresNames <- gsub('-std', 'StdDev', featuresNames)
featuresNames <- gsub('[-()]', '', featuresNames)
featuresNames <- gsub('^t', 'time', featuresNames)
featuresNames <- gsub('^f', 'frequency', featuresNames)
featuresNames <- gsub('Gyro', 'Gyroscope', featuresNames)
featuresNames <- gsub('BodyBody', 'Body', featuresNames)
featuresNames <- gsub('Acc', 'Accelerometer', featuresNames)
featuresNames <- gsub('Mag', 'Magnitude', featuresNames)
featuresNames <- gsub('Freq', 'Frequency', featuresNames)

## Load the test data
testSet <- read.table(file = paste(dir, "test", "X_test.txt", sep="/"))
testActivities <- read.table(file = paste(dir, "test", "y_test.txt", sep="/"))
testSubject <- read.table(file = paste(dir, "test", "subject_test.txt", sep="/"))

## Load the training data
trainingSet <- read.table(file = paste(dir, "train", "X_train.txt", sep="/"))
trainingActivities <- read.table(file = paste(dir, "train", "y_train.txt", sep="/"))
trainingSubject <- read.table(file = paste(dir, "train", "subject_train.txt", sep="/"))

## Merge datasets
test <- cbind(testSet[featuresWanted], testActivities, testSubject)
training <- cbind(trainingSet[featuresWanted], trainingActivities, trainingSubject)
full <- rbind(training, test)
colnames(full) <- c(featuresNames, "activity", "subject")

## Convert activity values to factor
full$activity <- factor(full$activity, levels = activityNames[,1], labels = activityNames[,2])

## Convert subject values to factor
full$subject <- as.factor(full$subject)

## Calculate average
average <- ddply(full, c("activity", "subject"), numcolwise(mean))

## Write dataset to file
write.table(average, file = "TidyDataSet.txt", row.names = FALSE, sep = "\t")
