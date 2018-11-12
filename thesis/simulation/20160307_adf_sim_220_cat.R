# 
# Simulation for categorical data
# 
# Number of categorical variable is 2. and Number of category for each variable is not fixed.
#
# s_x = w0 + w1x1 + w2x2
#


#set.seed(1009)
#seed <- .Random.seed
#save(seed, file="tmp.rda")
load("seed.rda")
.Random.seed <- seed

# Data creation step( just for x, y will be created later step
n_iter <- 100
n_max_cat <- 5
prob1 <- c(0.6, 0.4)
n_bucket <- 2^4; n_bucket
data_mat <- rmultinom(n_iter, n_max_cat, prob1)
data_mat[2,] <- data_mat[2,] + 10; data_mat
dat <- data.frame(C1=data_mat[1,], C3=data_mat[2,])

head(dat)

# Creating simulated true weight distribution.

mean_w <- rnorm(n = (n_bucket+1), mean = 0, sd = 10) #means of weights


var_w <- 0.1


get_w <- function(){
  w <- 0
  for( i in 1:(n_bucket+1) ){
    w_i <- rnorm(n = 1, mean = mean_w[i], sd = var_w)
    if( i == 1 ){
      w <- w_i
    } else {
      w <- c(w, w_i)
    }
  }
  return(w)
}



get_y <- function(x){
  w <- get_w(); w
  p <- get_p_cat(x, w)
  y <- rbinom(1, 1, p)
  
  return(y)
}


# Hasing features.
get_x <- function(csv_row, D){
  x <- 0
  len_csv_row <- length(csv_row)
  
  for( i in 1:len_csv_row) {
    # i <- 2
    var_name <- names(csv_row)[i]; var_name
    number_in_var_name <- substr(var_name,2, nchar(var_name)); number_in_var_name
  
    hex_num <- paste('0x', csv_row[i], number_in_var_name, sep=""); hex_num
    dec_num <- strtoi(hex_num); dec_num
    index <- dec_num %% D; index
    x <- c(x, index)
  }
  return(x)
}



# Hasing features with murmurhash3
get_mur_x <- function(csv_row, D){
  x <- 0
  len_csv_row <- length(csv_row)
  for( i in 1:len_csv_row) {
    hex_num <- digest(csv_row[i], algo="murmur32", serialize = TRUE, file = FALSE, seed = 0, errormode = "stop")
    dec_num <- as.numeric(paste('0x', hex_num, sep=""))
    index <- dec_num %% D;
    x <- c(x, index)
  }
  return(x)
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


# Function for calculate success probability of logistic model.(for hashed categorical variables)
# Param 1: x vector
# Param 2: w vector(beta)
# Output : success probability of logistic model
get_p_cat <- function(x, w, bounded = FALSE){
  wTx <- sum(w[x])

  bounded_wTx <- max( min(wTx, 10),-10 )
  
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
update_w_cat <- function(w, x, p, y, nu = 1000){  
  w[x] <- w[x] - (p - y)* 1 * alpha[x]
  return(w)
}




# Setting y for data
y <- NA
for( i in 1:n_iter ){
  
  x_i <- get_x(dat[i,]); x_i
  y_i <- get_y(x_i); y_i
  
  if( i == 1 ){
    y <- y_i
  } else {
    y <- c(y, y_i)
  }
}
dat$y <- y



# Simulation !!!!!!
alpha <- rep(c(0.1), n_bucket+1); alpha # plus one for bias term | using fixed alpha
w <- rep(c(0), n_bucket+1); w # plus one for bias term

for( i in 1:n_iter ){
  dat_i <- dat[i,]; dat_i
  y_i <- dat_i$y; y_i
  dat_i$y <- NULL # dropping y
  
  x_i <- get_x(csv_row = dat_i, D = n_bucket); x_i
  p_i <- get_p_cat(x_i, w)
  print(p_i)

  w <- update_w_cat(w, x_i, p_i, y_i)
}

w



# test code for get_x() and ...
csv_row <- dat[2,]; csv_row
csv_row$y <- NULL; csv_row
ts_x <- get_x(csv_row, n_bucket); ts_x
ts_y <- get_y(ts_x); ts_y



ts_colision_checker1 <- rep(0, 2^17)
ts_colision_checker2 <- rep(0, 2^17)

ts_colision_checker1 <- rep(0, n_bucket)
ts_colision_checker2 <- rep(0, n_bucket)
# need to change to dynamic alpha
for( i in 1:n_max_cat) {
  for( j in 1:n_max_cat) {
    csv_row$C1 <- i; csv_row$C3 <- j
    ts_x <- get_mur_x(csv_row, n_bucket)
    ts_colision_checker1[ts_x[2]] = ts_colision_checker1[ts_x[2]] + 1
    ts_colision_checker2[ts_x[3]] = ts_colision_checker2[ts_x[3]] + 1
  }
}

ts_colision_checker1
ts_colision_checker2


#install.packages("digest")
library(digest)
? digest

ts <- digest(c(122), algo="murmur32", serialize = TRUE, file = FALSE, seed = 0, errormode = "stop")
ts1 <- as.numeric(paste('0x', ts, sep=""))
log2(ts1)

