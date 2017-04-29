#ETL File

require(readr)
require(dplyr)


df <- readr::read_csv("../01 Data/inc5000_2016_raw.csv")

df <- df %>% dplyr::select(id, rank, workers, company, state_l, state_s, growth, revenue, industry, yrs_on_list)

# Get rid of special characters in each column.
# Google ASCII Table to understand the following:
for(n in names(df)) {
  df[n] <- data.frame(lapply(df[n], gsub, pattern="[^ -~]",replacement= ""))
}

na2emptyString <- function (x) {
  x[is.na(x)] <- ""
  return(x)
}
if(length(names(df)) > 0) {
  for(d in names(df)) {
    # Change NA to the empty string.
    df[d] <- data.frame(lapply(df[d], na2emptyString))
    # Get rid of " and ' in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="[\"']",replacement= ""))
    # Change & to and in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern="&",replacement= " and "))
    # Change : to ; in dimensions.
    df[d] <- data.frame(lapply(df[d], gsub, pattern=":",replacement= ";"))
  }
}

write.csv(df, file = "inc5000_2016_clean.csv",row.names=FALSE, na="")

print(head(df, 10))
