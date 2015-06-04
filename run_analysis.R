## Tyding Data - Wearable Computing

dataPath <- "./uci_har_dataset"
if(!file.exists(dataPath)){
    dir.create(dataPath)
}

# Download file and unzip it
destinationFilePath <- file.path(dataPath, "UCI_HAR_Dataset.zip")
if(!file.exists(destinationFilePath)){
    file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(url = file_url, destfile = destinationFilePath, method = "curl")
}
unzip(zipfile = destinationFilePath, exdir = ".")

# set the UCI HAR Dataset folder
uci_folder <- getwd()
uci_folder <- file.path(uci_folder, "UCI HAR Dataset")

# Import libraries
library(dplyr)
library(reshape2)

# IMPORT THE DATA
data_train_x <- read.table(file = file.path(uci_folder, "train", "X_train.txt"), header = FALSE)
data_train_y <- read.table(file = file.path(uci_folder, "train", "y_train.txt"), header = FALSE, col.names = "activity_id")

data_test_x <- read.table(file = file.path(uci_folder, "test", "X_test.txt"), header = FALSE)
data_test_y <- read.table(file = file.path(uci_folder, "test", "y_test.txt"), header = FALSE, col.names = "activity_id")

subject_train <- read.table(file = file.path(uci_folder, "train", "subject_train.txt"), header = FALSE, col.names = "subject_id")
subject_test <- read.table(file = file.path(uci_folder, "test", "subject_test.txt"), header = FALSE, col.names = "subject_id")

activity_labels <- read.table(file.path(uci_folder, "activity_labels.txt"), header = FALSE, col.names = c("activity_id", "activity_name"))
features <- read.table(file.path(uci_folder, "features.txt"), header = FALSE, col.names = c("feature_id", "feature_name"))

# 1. Merges the training and the test sets to create one data set.
merged_data <- rbind(data_test_x, data_train_x)
merged_labels <- rbind(data_test_y, data_train_y)
merged_subjects <- rbind(subject_test, subject_train)

# Rename columns based on features
names(merged_data) <- features$feature_name

# Column binding of the 3 merged datasets
data <- cbind(merged_data, merged_labels, merged_subjects)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_std_indexes <- grep("mean|std|activity_id|subject_id", names(data))
extracted_data <- data[, mean_std_indexes]

# 3. Uses descriptive activity names to name the activities in the data set
data_activity <- merge(extracted_data, activity_labels, by.x = "activity_id", by.y = "activity_id")

# 4. Appropriately labels the data set with descriptive variable names.
label_names <- names(data_activity)
label_names <- gsub("BodyBody", "Body", label_names)
label_names <- gsub("^t", "time_", label_names)
label_names <- gsub("^f", "frequency_", label_names)
label_names <- gsub("\\-", "_", label_names)
label_names <- gsub("\\(\\)", "", label_names)
names(data_activity) <- label_names

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
melted_data <- melt(data_activity, id = c("subject_id", "activity_name"))
casted_data <- dcast(melted_data, subject_id + activity_name ~ variable, mean)

# remove "activity_id" column because it doens't inform anything
final_data <- casted_data[, !(names(casted_data) %in% c("activity_id"))]

write.table(final_data, file = "./tidyData.txt", row.names = FALSE)









