library(tidyverse)
# install.packages("vtable")


df <- read_csv("matches_df_updated.csv")
# df <- read_csv("~/Documents/QAC385_ML/Project/matches_df.csv")

df <- df[-c(1,2,18,77)] # drops the irrelevant columns (id, attendance) from the dataframe

dfh<-df %>% filter(venue == "Home")

dfa<-df %>% filter(venue == "Away")

p1<-merge(x=dfh, y=dfa, by=c("referee" ="referee", "date" = "date", "time" = "time", "gameweek" = "gameweek"), suffixes = c("_team", "_opponent"))
p2<-merge(x=dfa, y=dfh, by=c("referee" ="referee", "date" = "date", "time" = "time", "gameweek" = "gameweek"), suffixes = c("_team", "_opponent"))

df_final<-rbind(p1,p2)
