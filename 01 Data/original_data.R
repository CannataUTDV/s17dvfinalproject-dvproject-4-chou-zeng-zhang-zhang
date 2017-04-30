# script that prints out original company data for markdown file
require(readxl)
require(readr)

df <- read_excel("../01 Data/DetailedStateInfoAP-CS-A-2006-2013-with-PercentBlackAndHIspanicByState-fixed.xlsx", sheet = "Sheet2")

print(head(df, 10))