# Install needed packages

if (!require("data.table")) {
        install.packages("data.table")
}

if (!require("reshape2")) {
        install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Change Directory
setwd("./UCI HAR Dataset")

# Load: activity.labels
activity.labels <- read.table("activity_labels.txt")[,2]

# Load: data column names
features <- read.table("features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extracted.features <- grepl("mean|std", features)

# Load and process X.test & y.test data.
x.test <- read.table("./test/X_test.txt")
y.test <- read.table("./test/y_test.txt")
subject.test <- read.table("./test/subject_test.txt")

names(x.test) = features

# Extract only mean and standard deviation for each measurement from x.test.
x.test = x.test[,extracted.features]

# Load activity.labels
y.test[,2] = activity.labels[y.test[,1]]
names(y.test) = c("activity.id", "activity.label")
names(subject.test) = "subject"

# Bind data
test.data <- cbind(as.data.table(subject.test), y.test, x.test)
rm(subject.test, x.test, y.test)

# Load and process x.train & y.train data.
x.train <- read.table("./train/X_train.txt")
y.train <- read.table("./train/y_train.txt")

subject.train <- read.table("./train/subject_train.txt")

names(x.train) = features

# Extract only mean and standard deviation for each measurement from x.train.
x.train = x.train[,extracted.features]

# Load activity.labels
y.train[,2] = activity.labels[y.train[,1]]
names(y.train) = c("activity.id", "activity.label")
names(subject.train) = "subject"

# Bind data
train.data <- cbind(as.data.table(subject.train), y.train, x.train)
rm(subject.train, y.train, x.train)

# Merge test and train data
data = rbind(test.data, train.data)
rm(test.data, train.data)


id.labels   = c("subject", "activity.id", "activity.label")
data.labels = setdiff(colnames(data), id.labels)
melt.data      = melt(data, id = id.labels, measure.vars = data.labels)

# Apply mean function to dataset using dcast function
tidy.data   = dcast(melt.data, subject + activity.label ~ variable, mean)

# Clean Workspace
rm(melt.data, id.labels, data.labels, data, activity.labels, extracted.features, features)

# Write to text file
setwd("..")
write.table(tidy.data, file = "./tidy_data.txt", row.name=FALSE)
