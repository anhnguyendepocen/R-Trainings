#### Introduction to R for Statistical Learning 
#### Urban Institute Training
### Alex C. Engler
### 9/9/2016

##############################################################

### More Resources:

## 1. R CRAN Task Views: https://cran.r-project.org/web/views/
# CRAN is the Comprehensive R Archive Network, tasked with storing R and all of its packages.
# 
# CRAN Task Views are guides to doing certain tasks in R that are maintained by experts in that area. Most critically, this includes an overview of the many packages that 

## 2. Introduction to Statistical Learning: http://www-bcf.usc.edu/~gareth/ISL/ISLR%20First%20Printing.pdf
# 
# Wonderful textbook for 'statistical learning' - which includes not only statistics, but also many of the foundational skills in machine learning and data science. Nine out of ten of these chapters also have an R tutorial at the end. 

## R for Data Science - Chapters 23/24/25: http://r4ds.had.co.nz/model-basics.html#visualising-models
# This new free ebook goes into depth explaining R models and shows a wide variety of tricks to analyze and visualize those models. 

##############################################################

## You should remove the '#' and install the packages below, if you do not have them already:
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("ggplot2")

library(dplyr) 
## dplyr 
# Convenient easy functions for subseting, reordering, adding columns, simple aggregations, simple random sampling
# Introduction here: https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

library(tidyr)
## tidyr
# Wide >> Long with gather()
# Long >> Wide with spread()
# Introduction here: http://blog.rstudio.org/2014/07/22/introducing-tidyr/

## General guide to tidyr and dplyr: https://rpubs.com/bradleyboehmke/data_wrangling

diamonds <- read.csv(file.choose(), header=TRUE)



## Three ways to look at the data:
head(diamonds) # See first six rows.
glimpse(diamonds) # Rotated display of the data (from dplyr package)
str(diamonds) # See data structure


## dplyr example:

# Simple functions for data manipulation:
new_data <- filter(diamonds, cut == "Ideal")
new_data <- group_by(new_data, channel)
new_data <- summarize(new_data, avg_price = mean(price))
new_data <- arrange(new_data, -avg_price)

# Can chain those operations together with the %>% operator:
new_data2 <- diamonds %>%
	filter(cut == "Ideal") %>%
	group_by(channel) %>%
	summarize(avg_price = mean(price)) %>%
	arrange(-avg_price)

new_data == new_data2
table(new_data == new_data2)

rm(new_data, new_data2) ## delete these dataframes


## dplyr's chain operators work into ggplot2 as well:
library(ggplot2)

diamonds %>%
	group_by(store) %>%
	summarize(avg_price = mean(price),
		med_carat = median(carat),
		count = n()) %>%
	filter(count > 10) %>%
	arrange(-avg_price) %>%
	ggplot(aes(x=med_carat, y=avg_price, color=store, size=count)) + 
		geom_point() + 
		ggtitle("Diamond Stores by Carat & Cost") +
		theme_bw()


## By default, R considers strings to be factors (R's categorical variables) upon loading. We can change the data type back to a string easily.
class(diamonds$store)
diamonds$store <- as.character(diamonds$store)
class(diamonds$store)

## Note you can also run:
# options(stringsAsFactors=FALSE)
## at the start of an R session, which will undo this default.

## Handy Descriptive Statistics:
mean(diamonds$price)
median(diamonds$price)
sd(diamonds$price)
fivenum(diamonds$price)

quantile(diamonds$price, 0.33)
quantile(diamonds$price, c(0.33,0.66))
quantile(diamonds$price, c(0.2,0.4,0.6,0.8))

cor(diamonds$carat, diamonds$price) ## correlation
cov(diamonds$carat, diamonds$price) ## covariance

## apply family of functions (more here: http://faculty.nps.edu/sebuttre/home/R/apply.html)
sapply(diamonds, mean)
sapply(diamonds, sd)




## Simple linear regression use lm()
linear_model <- lm(price ~ carat, data = diamonds)

linear_model
summary(linear_model) ## Quick Overview

attributes(linear_model)

# You can refer to individual attributes with the '$'
linear_model$call
linear_model$fitted.values

plot(linear_model$fitted.values, linear_model$residuals)


## Multivariate Linear Regression
linear_model2 <- lm(price ~ ., data = diamonds) ## Regress against all vars in dataframe

linear_model2 <- lm(price ~ . -store, data = diamonds) ## Regress against all vars in dataframe, except for 'store'

linear_model2 <- lm(price ~ carat + color + clarity + cut + channel, data = diamonds) ## Or specify variables to be included

summary(linear_model2)
plot(linear_model2)



# QQ Plots
qqnorm(linear_model2$residuals)
qqline(linear_model2$residuals)
hist(linear_model2$residuals) 

## Leverage and Outliers 
?influence.measures
hatvalues(linear_model2) ## check for leverage

cook_list <- cooks.distance(linear_model2) ## check for high influence 
outliers <- cook_list[cook_list > 0.05] 

## To look at the rows of data with high cooks distance:
# names(outliers)
# diamonds[names(outliers),]

# Interaction Effects with *
linear_model3 <- lm(price ~ carat*color + clarity + cut + channel, data = diamonds) 
summary(linear_model3)

# Interaction Effects with * and -
linear_model4 <- lm(price ~ carat*color - color + clarity + cut + channel, data = diamonds) 
summary(linear_model4)

# Weighting with "weight" argument:
linear_model5 <- lm(price ~ color + clarity + cut + channel, weight=carat, data = diamonds) 
summary(linear_model5)



## Analysis of Variance with anova()
# Performs chi-square test to check significance in RSS 
anova(linear_model2, linear_model3)
anova(linear_model, linear_model2, linear_model3)


## Generalized Linear Models use glm()
# GLM Overview: http://www.statmethods.net/advstats/glm.html
str(diamonds$cut)
table(diamonds$cut)

logistic_model <- glm(cut ~ price + carat + clarity + channel, data = diamonds, family = binomial)
summary(logistic_model)

logistic_model$coefficients
exp(logistic_model$coefficients)

## Can reoder factor if you prefer:
# diamonds$cut <- factor(diamonds$cut, levels=c("Not Ideal","Ideal"))


## CAR - Companion to Applied Regression
## install.packages("car")
library(car)

outlierTest(linear_model2) ## outlier tests using Bonferonni p-value
vif(linear_model2) ## Variance Influence Factors


## MASS - Modern Applied Statistics

library(MASS) 
r_lm <- rlm(price ~ carat + color + clarity + cut + channel, data = diamonds) ## Robust Linear Regression w/ IRLS
attributes(r_lm)



## Caret Package - For Applied Machine Learning 
# install.packages("caret")
library(caret)

rf_model <- train(price ~., data = diamonds, method="rf")
nnet_model <- train(price ~., data = diamonds, method="nnet")

## Model training with caret: http://topepo.github.io/caret/training.html
