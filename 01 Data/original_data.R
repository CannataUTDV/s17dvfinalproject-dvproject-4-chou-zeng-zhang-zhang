# script that prints out original company data for markdown file

require(readr)

df <- readr::read_csv("../01 Data/inc5000_2016_raw.csv")

print(head(df, 10))