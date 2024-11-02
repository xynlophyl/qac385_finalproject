library(tidyverse)
library(qacBase)
library(caret)


df <- read_csv("data/matches_df_updated.csv")
# df <- read_csv("~/Documents/QAC385_ML/Project/matches_df.csv")
df_2022_23 <- read.csv("data/matches-2022-2023.csv")


# Data prep ---------------------------------------------------------------

# Appending 2022-23 to previous seasons
df <- df %>%
  select(-`Unnamed: 0`, -`...1`)

df_2022_23 <- df_2022_23 %>%
  select(-X)

df_2022_23$date <- as.Date(df_2022_23$date)
df$time <- as.character(df$time)

df <- bind_rows(df, df_2022_23)

# Data wrangling to get to desired format
df <- df %>%
  select(-attendance)


dfh<-df %>%
  filter(venue == "Home")

dfa<-df %>%
  filter(venue == "Away")

p1<-merge(x=dfh, y=dfa, by=c("referee" ="referee", "date" = "date", "time" = "time", "gameweek" = "gameweek"))

p2<-merge(x=dfa, y=dfh, by=c("referee" ="referee", "date" = "date", "time" = "time", "gameweek" = "gameweek"))

df_final<-rbind(p1,p2)

df <- df_final

# write_csv(df, "matches_df3.csv")

# For later, so we can cbind with predicted values
df_info <- df %>%
  select(season.x, team.x, opponent.x, venue.x, xg.x)

cor <- cor(select_if(df, is.numeric), method = "pearson")

# Remove unnecessary variables
df <- df %>%
  select(gf.x, season.x,
         # x
         poss.x, sh.x, sot.x, fk.x, tkl.x:inter.x, pass_cmp.x:pass_prgdist.x, pass_kp.x:pass_prog.x, 
         # sca_passlive.x:sca_def.x, 
         # include or not?
         sca.x, sh.x,
         touches.x:progpass_rec.x, fls.x:arllost.x,
         # y
         tkl.y:inter.y, recov.y
         )

# colnames(df)

# renaming variables for improved clarity
df <- df %>%
  rename("ShotsOnTargetX" = sot.x,
         "SuccCrossesIntoBoxX" = pass_crspa.x,
         "ShotsX" = sh.x,
         "FreeKickShotsX" = fk.x,
         "SuccPassIntoBoxX" = pass_ppa.x,
         "OffsidesX" = off.x,
         "TouchesInBoxX" = touches_attpen.x,
         "ShotCreatingActionsX" = sca.x,
         "RecoveriesX" = recov.x,
         "FoulsDrawnX" = fld.x)

# histograms(df %>% select(gf.x, xg.x))

# Split into train/test ---------------------------------------------------

set.seed(1234)
index <- createDataPartition(df$gf.x, p = .8, list = FALSE)
train <- df[index, ]
test  <- df[-index, ]


# df$season.x <- as.character(df$season.x)
# train <- df %>% filter(season.x != "2022_2023")
# test <- df %>% filter(season.x == "2022_2023")


train <- train %>% select(-season.x)
test <- test %>% select(-season.x)

histograms(train %>% select(gf.x))

# Wrangling from before Henrick's magic ------------------------------------
# 
# #checks where and how many na there are after dropping attendance 
# which(is.na(df))
# sum(is.na(df))
# 
# df_info <- df %>%
#   select(season, team, opponent, venue, xg)
# 
# # variables to remove from model?
# df <- df %>%
#   # id variables/other info variables
#   select(-season:-venue, -opponent, -captain:-referee, -match_id) %>%
#   # xG or related (should we have shot dist or no? too similar to xG?)
#   select(-xg, -xga, -dist, -psxg, -psxg_pm, -xag, -xa) %>%
#   # other
#   select(-pkscored, -pkatt, -crdy, -crdr, -twocrdy) %>%
#   # GCA
#   select(-gca:-gca_def)
# 
# 
# # removing shot stuff and defensive stuff
# # df <- df %>%
# #   # shot stuff
# #   select(-sh, -sot, -fk, -sca:-sca_def, -pass_kp, -pass_crspa)
# 
# # df <- df %>%
# #   select(-sot)
# 
# df <- df %>%
#   # def stuff
#   select(-err, -sota, -saves)
# 
# 
# df <- df %>%
#   # just for model
#   select(-result, -ga, -touches_attpen)



# Models ------------------------------------------------------------------



# touches_attpen.x + touches.x
# touches_attpen.x + touches.x  + poss.x + pass_rec.x + dist.x + apa3 + att3rdpc

control <- trainControl(method = "cv", number = 10)

# Linear regression -------------------------------------------------------
set.seed(1234)
model.lm <- train(gf.x ~ .,
                  data = train,
                  method = "lm",
                  trControl = control, 
                  metric = "RMSE")

summary(model.lm)

plot(varImp(model.lm), top = 5)


# Lasso (elastic net) -----------------------------------------------------
lambda <- 10^seq(-3, 3, length = 100)

set.seed(1234)
model.lasso <- train(
  gf.x ~ ., 
  data = train, 
  method = "glmnet",
  metric = "RMSE",
  trControl = control,
  tuneGrid = data.frame(alpha = 1, lambda = lambda)
)

model.lasso
coef(model.lasso$finalModel, model.lasso$bestTune$lambda)
summary(model.lasso)

# varimp_lasso <- as.data.frame(varimp_lasso$importance)


plot(varImp(model.lasso), top = 10)


# Backward stepwise selection with AIC ------------------------------------
set.seed(1234)
model.stepAIC <- train(gf.x ~ ., data = train,
                       method="lmStepAIC",
                       direction = "backward",
                       trControl = control)
model.stepAIC
summary(model.stepAIC)


# ANN ---------------------------------------------------------------------

# library(neuralnet)
# 
# train.control <- trainControl(method="none")
# tune.grid.neuralnet <- expand.grid(
#   layer1 = 1,
#   layer2 = 0,
#   layer3 = 0
# )
# system.time({
#   set.seed(1234)
#   model.ann <- train(gf.x ~ ., 
#                      data=train,
#                      method="neuralnet",
#                      tuneGrid=tune.grid.neuralnet,
#                      metric="RMSE",
#                      trControl=train.control,
#                      preProcess=c("range"),
#                      stepmax=1e6)
#   
# })
# 
# 
# plot(model.ann$finalModel)


# Random forest -----------------------------------------------------------
set.seed(1234)
model.rf <- train(gf.x ~ ., 
                    data = train, 
                    method = "rf",
                    metric = "RMSE",
                    ntree = 100,
                    trControl = control)
model.rf

varImp(model.rf)



# Gradient boosting -------------------------------------------------------
library(gbm)

set.seed(1234)
model.gbm <- train(gf.x ~ .,
                   data = train,
                   method = "gbm",
                   trControl = control,
                   metric = "RMSE",
                   verbose = FALSE,
                   tuneLength = 5)   

varImp(model.gbm)


# XGBoost -----------------------------------------------------------------

library(xgboost)

set.seed(1234)
model.xgb <- train(gf.x ~ .,
                   data = train,
                   method = "xgbTree",
                   trControl = control,
                   metric = "RMSE",
                   verbose = FALSE,
                   tunelength = 5)   

varImp(model.xgb)


# Poisson regression ------------------------------------------------------

model.poisson <- train(gf.x ~ .,
                  data = train,
                  family = "poisson",
                  trControl = control, 
                  metric = "RMSE")

model.poisson
plot(varImp(model.poisson))


# Adding predictions ------------------------------------------------------
library(modelr)
df <- df %>%
  add_predictions(model.lasso, var = "lasso") %>%
  add_predictions(model.lm, var = "lm") %>%
  add_predictions(model.stepAIC, var = "step") %>%
  add_predictions(model.rf, var = "rf") %>%
  add_predictions(model.gbm, var = "gbm") %>%
  add_predictions(model.xgb, var = "xgb") %>%
  add_predictions(model.poisson, var = "poisson")

length(predict(model.poisson, df))

df_final <- cbind(df_info, df)

df_final <- df_final[-1]
test_pred <- df_final[-index, ]
# 

# test_pred <- df_final %>% filter(season.x == "2022_2023")

postResample(mean(test_pred$gf.x), test_pred$gf.x)
postResample(test_pred$xg.x, test_pred$gf.x)
postResample(test_pred$lasso, test_pred$gf.x)
postResample(test_pred$lm, test_pred$gf.x)
postResample(test_pred$step, test_pred$gf.x)
postResample(test_pred$rf, test_pred$gf.x)
postResample(test_pred$gbm, test_pred$gf.x)
postResample(test_pred$xgb, test_pred$gf.x)
postResample(test_pred$poisson, test_pred$gf.x)
postResample(test_pred$poissonlasso, test_pred$gf.x)

inter <- postResample(mean(test_pred$gf.x), test_pred$gf.x)
xg <- postResample(test_pred$xg.x, test_pred$gf.x)
Lasso <- postResample(test_pred$lasso, test_pred$gf.x)

testperf <- bind_rows(inter, xg, poisson) %>%
  mutate(Model = c("Intercept-only", "Opta xG", "Lasso"), .before = RMSE) %>%
  mutate(Model = fct_reorder(Model, RMSE))

testperf %>%
  ggplot(mapping = aes(RMSE, Model)) +
  geom_point(size = 3) +
  theme_bw() +
  theme(axis.title.y = element_blank())
  


# Analysis (ignore this,  it's for full season) ---------------------------

# Whole dataset
sum <- df_final %>%
  group_by(season.x, team.x) %>%
  summarize(tot_gf = sum(gf.x), tot_xg = sum(xg.x), tot_lasso = sum(lasso), tot_lm = sum(lm), 
            tot_step = sum(step), tot_rf = sum(rf), tot_gbm = sum(gbm), tot_xgb = sum(xgb), tot_poisson = sum(poisson),
            sd_xg = sd(xg.x), sd_lasso = sd(lasso), sd_lm = sd(lm), sd_step = sd(step), 
            sd_rf = sd(rf), sd_gbm = sd(gbm), sd_xgb = sd(xgb), sd_poisson = sd(poisson)) %>%
  mutate(diff_xg = tot_xg - tot_gf, diff_lasso = tot_lasso - tot_gf, diff_lm = tot_lm - tot_gf, 
         diff_step = tot_lm - tot_step, diff_rf = tot_lm - tot_rf, diff_gbm = tot_lm - tot_gbm,
         diff_xgb = tot_lm - tot_xgb, diff_poisson = tot_lm - tot_poisson) %>%
  ungroup()

postResample(sum$tot_gf, sum$tot_xg)
postResample(sum$tot_gf, sum$tot_lasso)
postResample(sum$tot_gf, sum$tot_lm)
postResample(sum$tot_gf, sum$tot_step)
postResample(sum$tot_gf, sum$tot_rf)
postResample(sum$tot_gf, sum$tot_gbm)
postResample(sum$tot_gf, sum$tot_xgb)
postResample(sum$tot_gf, sum$tot_poisson)

sum %>% summarize(mean_sd_xg = mean(sd_xg), mean_sd_lasso = mean(sd_lasso), mean_sd_lm = mean(sd_lm), 
                  mean_sd_step = mean(sd_step), mean_sd_rf = mean(sd_rf), mean_sd_gbm = mean(sd_gbm),
                  mean_sd_xgb = mean(sd_xgb), mean_sd_poisson = mean(sd_poisson))

# Test dataset
sum <- test_pred %>%
  group_by(season.x, team.x) %>%
  summarize(tot_gf = sum(gf.x), tot_xg = sum(xg.x), tot_lasso = sum(lasso), tot_lm = sum(lm), 
            tot_step = sum(step), tot_rf = sum(rf), tot_gbm = sum(gbm), tot_xgb = sum(xgb), tot_poisson = sum(poisson),
            sd_xg = sd(xg.x), sd_lasso = sd(lasso), sd_lm = sd(lm), sd_step = sd(step), 
            sd_rf = sd(rf), sd_gbm = sd(gbm), sd_xgb = sd(xgb), sd_poisson = sd(poisson)) %>%
  mutate(diff_xg = tot_xg - tot_gf, diff_lasso = tot_lasso - tot_gf, diff_lm = tot_lm - tot_gf, 
         diff_step = tot_lm - tot_step, diff_rf = tot_lm - tot_rf, diff_gbm = tot_lm - tot_gbm,
         diff_xgb = tot_lm - tot_xgb, diff_poisson = tot_lm - tot_poisson) %>%
  ungroup()

postResample(sum$tot_gf, sum$tot_xg)
postResample(sum$tot_gf, sum$tot_lasso)
postResample(sum$tot_gf, sum$tot_lm)
postResample(sum$tot_gf, sum$tot_step)
postResample(sum$tot_gf, sum$tot_rf)
postResample(sum$tot_gf, sum$tot_gbm)
postResample(sum$tot_gf, sum$tot_xgb)
postResample(sum$tot_gf, sum$tot_poisson)

sum %>% summarize(mean_sd_xg = mean(sd_xg), mean_sd_lasso = mean(sd_lasso), mean_sd_lm = mean(sd_lm), 
                  mean_sd_step = mean(sd_step), mean_sd_rf = mean(sd_rf), mean_sd_gbm = mean(sd_gbm),
                  mean_sd_xgb = mean(sd_xgb), mean_sd_poisson = mean(sd_poisson))



library(qacBase)
cor_plot(sum)

lm <- lm(tot_gf ~ tot_lasso,
         data = sum)

summary(lm)

df_final %>%
  summarize(mean_gf = mean(gf), mean_xg = mean(xg), mean_pred = mean(lasso),
            sd_gf = sd(gf), sd_xg = sd(xg), sd_lasso = sd(lasso))


sum %>%
  ggplot(mapping = aes(tot_lasso, tot_gf)) +
  geom_point() +
  expand_limits(x = c(0, 100), y = c(0, 100)) +
  geom_abline(slope = 1, intercept = 0)




# Compare models ------------------------------------
pred.lm <- predict(model.lm, test)
pred.lasso <- predict(model.lasso, test)

postResample(pred.lm, test$gf.x)
postResample(pred.lasso, test$gf.x)

postResample(df_final[-index, "xg.x"], test$gf.x)

# compare models
results <- resamples(list("Linear" = model.lm,
                          "Lasso" = model.lasso,
                          # "Step" = model.stepAIC,
                          "Random Forest" = model.rf,
                          "GBM" = model.gbm,
                          "XGBoost" = model.xgb,
                          "Poisson" = model.poisson))

summary(results)
bwplot(results, aspect = 1.6)
dotplot(results)
