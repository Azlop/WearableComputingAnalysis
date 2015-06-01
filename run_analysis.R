## Tyding Data - Wearable Computing
setwd("~/Documents/Big_Data/03_Getting_Cleaning_Data/")

# Import libraries
library(dplyr)
library(reshape2)

# IMPORT THE DATA
data_train_x <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
data_train_y <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE, col.names = "activity_id")

data_test_x <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
data_test_y <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE, col.names = "activity_id")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE, col.names = "subject_id")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE, col.names = "subject_id")

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names = c("activity_id", "activity_name"))
features <- read.table("UCI HAR Dataset/features.txt", header = FALSE, col.names = c("feature_id", "feature_name"))

# 1. Merges the training and the test sets to create one data set.
merged_data <- rbind(data_test_x, data_train_x)
merged_labels <- rbind(data_test_y, data_train_y)
merged_subjects <- rbind(subject_test, subject_train)

# Rename columns based on features
names(merged_data) <- features$feature_name

# Column binding of the 3 merged datasets
data <- cbind(merged_data, merged_labels, merged_subjects)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_std_indexes <- grep("(mean|std|activity_id|subject_id)", features$feature_name)
resize_data <- merged_data[, mean_std_indexes]

# 3. Uses descriptive activity names to name the activities in the data set
data_activity <- merge(data, activity_labels, by.x = "activity_id", by.y = "activity_id")

# 4. Appropriately labels the data set with descriptive variable names.
label_names <- names(data_activity)
label_names <- gsub("BodyBody", "Body", label_names)
label_names <- gsub("^t", "time_", label_names)
label_names <- gsub("^f", "frequency_", label_names)
names(data_activity) <- label_names

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
melted_data <- melt(data_activity, id = c("subject_id", "activity_name"))
casted_data <- dcast(melted_data, subject_id + activity_name ~ variable, mean)
write.table(casted_data, file = "./tidyData.txt", row.names = FALSE)









