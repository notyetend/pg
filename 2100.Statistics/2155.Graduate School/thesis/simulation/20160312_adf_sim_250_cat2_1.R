# Categorical varlabie test with titanic data & online gradient descent
# Data from [https://www.kaggle.com/c/titanic/data?train.csv#_=_]
#


#load("seed.rda")
#.Random.seed <- seed



####################################################
# MLE 
####################################################

###
# Loading and pre-processing training data.
training.data.raw <- read.csv('./data/train.csv', header=T, na.strings=c(""))
head(training.data.raw)

# Checking if how many NA or unique values are there.
sapply(training.data.raw, function(x) sum(is.na(x)))
sapply(training.data.raw, function(x) length(unique(x)))

# Subsetting data dropping index, Name, Ticket and Cabin
data <- subset(training.data.raw, select=c(2,3,5,6,7,8,10,12))
head(data)

# Missing value imputation with mean value
data$Age[is.na(data$Age)] <- mean(data$Age, na.rm=T)

#
data <- data[!is.na(data$Embarked),]
rownames(data) <- NULL # This will re-create rownames as row-index
head(data)


train <- data[1:800,]
test <- data[801:889,]
rownames(test) <- NULL # Resetting rownames

model <- glm(Survived ~.,family=binomial(link='logit'),data=train)
summary(model)


fitted.results_p <- predict(model,newdata=subset(test,select=c(2,3,4,5,6,7,8)),type='response')
fitted.results_p
fitted.results_y <- ifelse(fitted.results > 0.5,1,0)
fitted.results_y

test$Survived

misClasificError <- mean(fitted.results != test$Survived)
print(paste('Accuracy',1-misClasificError))
# Accuracy
# 0.842696629213483 with MLE


get_metric <- function(prediction, actual){
  TP <- 0; FP <- 0; FN <- 0; TN <- 0;
  for( i in 1:length(actual)) {
    if(actual[i] == 1){
      if(prediction[i] == 1)
        TP <- TP + 1
      else
        FN <- FN + 1
    } else {
      if( prediction[i] == 1)
        FP <- FP + 1
      else
        TN <- TN + 1
    }
  }
  Precision <- TP / (TP+FP)
  Recall <- TP / (TP+FN)
  
  return(data.frame(TP=TP, FP=FP, FN=FN, TN=TN, Accuracy=((TP+TN)/length(actual)), Precision=Precision, Recall=Recall, F1=2*Precision*Recall/(Precision+Recall)  ))
}


log_loss_mle <- 0
for( i in 1:length(test$Survived)){
  log_loss_mle <- log_loss_mle + get_logloss(fitted.results_p[i], test$Survived[i])
}
log_loss_mle


get_metric(test$Survived, fitted.results)


















####################################################
# Using Hash trick and Online Gradient Descent 
####################################################

library(digest)
head(train)

# Function for calculate logloss
# Param 1: Predicted probability value that is between 0 and 1
# Param 2: Real success(1) or fail(0) value.
# Output : logloss, bigger when the difference of params is bigger or vice versa
get_logloss <- function(p, y){
  p = max(min(p, 1. - 10e-12), 10e-12)
  
  if(y==1){
    return(-log(p))
  } else {
    return(-log(1.0 - p))
  }
}




# Function for calculate success probability of logistic model.(for hashed categorical variables)
# Param 1: x vector
# Param 2: w vector(beta)
# Output : success probability of logistic model
get_p_cat <- function(w, x, bounded = FALSE){
  wTx <- sum(w[x])
  
  bounded_wTx <- max( min(wTx, 20),-20 )
  
  if( bounded ){
    return(1 / (1+exp(-bounded_wTx)))
  } else{
    return(1 / (1+exp(-wTx)))
  }
}


# 
# Function for update w with simle gradient descent having fixed alpha
# 
# I don't know yet or forgot why formula looks like this...
# (p-y)*x ... Is this 1st order differential equation of logistic formula?
update_w_cat <- function(w, x, n, p, y, nu = 1000){  
  
  w[x] <- w[x] - (p - y)* 1 * (alpha[x])
  
  return(w)
}


update_n <- function(x, n) {
  
  n[x] <- n[x] + 1
  # sqrt(n[x] + 1))
  return(n)
  
}




# murmurhashing version 3
get_mur_x_v3 <- function(df_row){
  #df_row <- train[2,-1]; df_row  # test
  x <- 1
  df_name_n_value <- paste(names(df_row), df_row, sep="" ); df_name_n_value
  df_row_length <- length(df_row); df_row_length
  
  for( i in 1:df_row_length) {
    #i <- 3
    #hex_num <- digest(df_name_n_value[i], algo="murmur32", serialize = TRUE, file = FALSE, seed = 0, errormode = "stop"); hex_num
    hex_num <- digest(df_name_n_value[i], algo="murmur32", serialize = TRUE, file = FALSE, seed = 0); hex_num
    dec_num <- as.numeric(paste('0x', hex_num, sep="")); dec_num
    index <- dec_num %% D; index
    x <- c(x, index); x
  }
  return(x)
}




# Trainning
D <- 2^10; D # number of weights
log_loss_ogd <- 0
df_log_loss_ogd <- data.frame(loss = 0)

alpha = rep(0.25, D); alpha
w <- rep(0, D); w
n <- rep(0, D); n

n_iter <- nrow(train); n_iter
for(i in 1:n_iter){
  #i <- 1
  
  x_raw <- train[i,-1]; x_raw
  x <- get_mur_x_v3(x_raw); x
  y <- train[i,1]; y
  p <- get_p_cat(w, x, TRUE); p
  w <- update_w_cat(w, x, n, p, y)
  n <- update_n(x, n)
  
  # Predicted success probability
  p_new <- get_p_cat(x=x, w=w, bounded = TRUE)
  
  # History of logloss
  log_loss_ogd <- log_loss_ogd + get_logloss(p_new, y)
  df_log_loss_ogd <- rbind(df_log_loss_ogd, log_loss_ogd/i)
  
}
w
n_iter <- nrow(train); n_iter
plot(seq(1:n_iter), df_log_loss_ogd[-1,], type='l')




# Test
log_loss_ogd <- 0
n_iter <- nrow(test); n_iter
prediction_sgd_p <- NULL; prediction_sgd_p
prediction_sgd_y <- NULL; prediction_sgd_y
for(i in 1:n_iter){
  #i <- 1
  
  x_raw <- test[i,-1]; x_raw
  x <- get_mur_x_v3(x_raw); x
  y <- test[i,1]; y
  p <- get_p_cat(w, x, TRUE); p
  
  log_loss_ogd <- log_loss_ogd + get_logloss(p, y)
  
  prediction_sgd_p <- c(prediction_sgd_p, p); prediction_sgd_p
  prediction_sgd_y <- c(prediction_sgd_y, ifelse(p > 0.5, 1, 0)); prediction_sgd_y
}
prediction_sgd_p
prediction_sgd_y
test[,1]
mean(prediction_sgd_y == test[,1])

log_loss_ogd

# Accuracy
# 0.842696629213483 with MLE
# 0.8202247 with ogd (alpha = 0.05)
# 0.8202247 with ogd (alpha = 0.1)
# 0.8314607 with ogd (alpha = 0.2) <
# 0.8314607 with ogd (alpha = 0.3) <
# 0.8089888 with ogd (alpha = 0.4)
# 0.7977528 with ogd (alpha = 0.5)
# 0.7977528 with ogd (alpha = 0.6)
# 0.7752809 with ogd (alpha = 0.7)
# 0.7752809 with ogd (alpha = 0.8)












#######################################################
# Using Hash trick and Assumed Density Filtering
#######################################################

head(train)
D <- 2^10; D # number of weights



# Package for gaussian quadrature
#install.packages("gaussquad")
library(gaussquad)

# Getting gaussian quadrature values.
poly_order <- 10
rule <-hermite.h.quadrature.rules(poly_order)
xxi <- rule[[10]][1]; xxi
wwi <- rule[[10]][2]; wwi
xxi
wwi
# Getting mean and variance of posterior distribution of s_t
get_s_t_new <- function(y, s_t_m_old, s_t_v_old){
  
  wi <- wwi / sqrt(pi)
  xi <- xxi * sqrt(2) * sqrt(s_t_v_old) + s_t_m_old
  
  fw <- 0
  if( y==1 ){
    fw <- 1 / (1+exp(-xi)) * wi
  } else {
    fw <- exp(-xi) / (1+exp(-xi)) * wi
  }
  
  z_t <- sum(fw)
  s_t_m_new <- 1/z_t * sum(xi * fw)
  s_t_v_new <- 1/z_t * sum((xi^2)*fw) - s_t_m_new^2
  
  return(c(s_t_m_new, s_t_v_new))  
}





get_a_i_cat <- function(x, theta_t_v){
  
  
  return(1 * theta_t_v[x] / sum(1^2 * theta_t_v[x]))
  
  #return(x*(theta_t_v) / sum(x^2 * theta_t_v))
  
}




update_theta_cat <- function(x, theta_t_m, theta_t_v, delta_m, delta_v, nu = 1000){

  a_i <- get_a_i_cat(x, theta_t_v); a_i
  
  theta_t_m[x] <- theta_t_m[x] + (a_i * delta_m); 
  theta_t_v[x] <- theta_t_v[x] + (a_i^2 * delta_v) #+ abs(theta_t_m[x])/min(nu, 3000)
  
  return(data.frame(m = theta_t_m, v = theta_t_v))
}






# Function for calculate logloss
# Param 1: Predicted probability value that is between 0 and 1
# Param 2: Real success(1) or fail(0) value.
# Output : logloss, bigger when the difference of params is bigger or vice versa
get_logloss <- function(p, y){
  p = max(min(p, 1. - 10e-12), 10e-12)
  
  if(y==1){
    return(-log(p))
  } else {
    return(-log(1.0 - p))
  }
}


###########
# Trainning
log_loss_adf <- 0
df_log_loss_adf <- data.frame(loss = 0)

# Initial value for mean and variance of theta(parameter)
theta_t_m <- rep(0, D+1)
theta_t_v <- rep(0.1, D+1)

w <- rep(0, D+1); w
n_iter <- nrow(train); n_iter
for( i in 1:n_iter ){
  #xi <- c(1, train[i,]$x1)
  #yi <- df[i,]$y
  
  # i <- 1 # test
  
  x_raw <- train[i,-1]; x_raw
  x <- get_mur_x_v3(x_raw); x
  y <- train[i,1]; y
  p <- get_p_cat(w, x, TRUE); p
  
  
  # Predictive distribution for s_t ~ N(s_t_m_old, s_t_v_old)
  s_t_m_old <- sum(theta_t_m[x] * 1); s_t_m_old # sum(wTx)
  s_t_v_old <- sum(theta_t_v[x] * (1^2)); s_t_v_old # sum(wTx^2)
  
  # Posterior distribution for s_t
  s_t_new <- get_s_t_new(y, s_t_m_old, s_t_v_old); s_t_new
  s_t_m <- s_t_new[1]
  s_t_v <- s_t_new[2]
  
  # Changes in s_t
  delta_m <- s_t_m - s_t_m_old; delta_m
  delta_v <- s_t_v - s_t_v_old; delta_v
  
  # Updating theta
  theta_t <- update_theta_cat(x, theta_t_m, theta_t_v, delta_m, delta_v, i)
  theta_t_m <- theta_t$m; theta_t_m
  theta_t_v <- theta_t$v; theta_t_v
  
  
  # Error checking if variance is droped into negative value.
  if( sum(sign(theta_t_v) == rep(-1, length(theta_t_v))) >= 1 ){
    print(i)
    print(theta_t_v)
    break()
  }
  
  
  # Predicted success probability
  p_new <- get_p_cat(x=x, w=theta_t_m, bounded = TRUE)
  
  
  # History for mean and variance of theta
  #df_theta_t_m <- rbind(df_theta_t_m, theta_t_m)
  #df_theta_t_v <- rbind(df_theta_t_v, theta_t_v)
  
  # History of logloss
  log_loss_adf <- log_loss_adf + get_logloss(p_new, y)
  df_log_loss_adf <- rbind(df_log_loss_adf, log_loss_adf/i)
}

df_log_loss_adf

n_iter <- nrow(train); n_iter
plot(seq(1:n_iter), df_log_loss_adf[-1,], type='l')



theta_t_m
theta_t_v







###########
# Test
log_loss_adf <- 0
n_iter <- nrow(test); n_iter
prediction_adf_p <- NULL; prediction_adf_p
prediction_adf_y <- NULL; prediction_adf_y
for(i in 1:n_iter){
  #i <- 1
  
  x_raw <- test[i,-1]; x_raw
  x <- get_mur_x_v3(x_raw); x
  y <- test[i,1]; y
  p <- get_p_cat(theta_t_m, x, FALSE); p
  
  log_loss_adf <- log_loss_adf + get_logloss(p, y)
  
  prediction_adf_p <- c(prediction_adf_p, p); prediction_adf_p
  prediction_adf_y <- c(prediction_adf_y, ifelse(p > 0.5, 1, 0)); prediction_adf_y
}
prediction_adf_p
prediction_adf_y
test[,1]
mean(prediction_adf_y == test[,1])

log_loss_adf
# Accuracy
# 0.842696629213483 with MLE
# 0.8202247 with ogd (alpha = 0.05)
# 0.8202247 with ogd (alpha = 0.1)
# 0.8314607 with ogd (alpha = 0.2) <
# 0.8314607 with ogd (alpha = 0.3) <
# 0.8089888 with ogd (alpha = 0.4)
# 0.7977528 with ogd (alpha = 0.5)
# 0.7977528 with ogd (alpha = 0.6)
# 0.7752809 with ogd (alpha = 0.7)
# 0.7752809 with ogd (alpha = 0.8)
# 0.8089888 with ADF (initial variance = 1)
# 0.8314607 with ADF (initial variance = 2) <
# 0.8314607 with ADF (initial variance = 3) <
# 0.8314607 with ADF (initial variance = 4) <
# 0.8314607 with ADF (initial variance = 5) <
# 0.8314607 with ADF (initial variance = 6) <
# 0.8314607 with ADF (initial variance = 7) <
# 0.8314607 with ADF (initial variance = 8) <
# 0.8314607 with ADF (initial variance = 9) <
# 0.8202247 with ADF (initial variance = 10)


get_metric(test$Survived, fitted.results)
get_metric(test[,1], prediction_sgd_y)
get_metric(test[,1], prediction_adf_y)

###############
# Plot
###############
n_iter <- nrow(train); n_iter
plot(seq(1:n_iter), df_log_loss_ogd[-1,], type='l', ylim = c(0, 0.4), ylab = "Average log-loss for training", xlab = "Iteration", col = "Blue")
lines(seq(1:n_iter), df_log_loss_adf[-1,], type='l', col = "Red")
legend(630, 0.37, c("OGD", "ADF"), lty=c(1,1), lwd=c(2.5,2.5), col=c("Blue", "Red"), bty='n', cex=0.75)




#install.packages("ROCR")
library(ROCR)
pred_mle <- prediction(fitted.results_p, test$Survived)
perf_mle <- performance(pred_mle,"tpr","fpr")

pred_sgd <- prediction(prediction_sgd_p, test$Survived)
perf_sgd <- performance(pred_sgd,"tpr","fpr")

pred_adf <- prediction(prediction_adf_p, test$Survived)
perf_adf <- performance(pred_adf,"tpr","fpr")

plot(perf_mle, col = "Green")
par(new=TRUE)
plot(perf_sgd, col = "Red")
par(new=TRUE)
plot(perf_adf, col = "Blue")
abline(0,1)

log_loss_mle
log_loss_ogd
log_loss_adf
