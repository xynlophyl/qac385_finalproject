library(tidyverse)
# install.packages("vtable")


df <- read_csv("matches_df.csv")
# df <- read_csv("~/Documents/QAC385_ML/Project/matches_df.csv")

df <- df[-c(1,2)] # drops the id columns (row id) from the dataframe

summary(df)

