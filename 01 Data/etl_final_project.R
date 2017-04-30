# ETL for AP CS 2013 datasets
# Require necessary packages
require(readxl)
require(data.world)

# Read Excel sheet to dataframe
# df <- read_excel("./01 Data/DetailedStateInfoAP-CS-A-2006-2013-with-PercentBlackAndHIspanicByState-fixed.xlsx", sheet = "Sheet2")
df <- read_excel("../01 Data/DetailedStateInfoAP-CS-A-2006-2013-with-PercentBlackAndHIspanicByState-fixed.xlsx", sheet = "Sheet2")

# Remove empty column from dataframe
df <- subset(df, select = -c(X__1))

# Remove last 4 rows of dataframe
n <- dim(df)[1]
df <- df[1:(n-4), ]

# Remove asterisks (*) from dataframe and replace with ""
df <- lapply(df, function(x) {
  gsub("\\*", "", x)
})

# Dataframe turns into a list. Need to revert back to datafram
df <- data.frame(df)

# Replace any record that is "" with NA
df[df == ""] <- NA

# Rename columns of dataframe
colnames(df) <- c("state", "number_of_schools", "total_takers", "yield_per_teacher", 
                  "total_passed", "percent_passed", 
                  "total_female","total_female_passed", "percent_female_passed", "percent_female_taking", 
                  "total_black", "total_black_passed", "percent_black_passed", "percent_black_taking", "percent_black_state", "attempt_rate_black", 
                  "total_black_females", "total_black_females_passed", "percent_black_females_passed", 
                  "total_hispanic", "total_hispanic_passed", "percent_hispanic_passed", 
                  "total_hispanic_female", "total_hispanic_female_passed", "percent_hispanic_female_passed", "percent_hispanic_taking", "percent_hispanic_state", "attempt_rate_hispanic")

#print the df so the notebook can see the dataset
print(head(df, 10))
# Write finished dataframe to csv file
write.csv(df, file = "ap_cs_2013_states_clean.csv", row.names=FALSE, na="")


############################################################
# Steps for creating csv of ACS 2015 Census Data
# 1. Used query tool on ACS 2015 Income dataset from the Census Bureau account on data.world.
# 2. Downloaded query result as as csv file and uploaded to our data.world dataset.







