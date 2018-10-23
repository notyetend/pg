##################################################
# Enviroment setting

# Required libraries
library(digest)
library(gaussquad) # Package for gaussian quadrature
# 
# 
# 
# 
# 


##################################################
# Function Definitions

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


# Function for calculate success probability of logistic model.(for hashed categorical variables)
# Param 1: x vector
# Param 2: w vector(beta)
# Output : success probability of logistic model
get_p_cat <- function(w, x, bounded = FALSE){
  wTx <- sum(w[x])
  
  bounded_wTx <- max( min(wTx, 10),-10 )
  
  if( bounded ){
    return(1 / (1+exp(-bounded_wTx)))
  } else{
    return(1 / (1+exp(-wTx)))
  }
}


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


update_theta_cat <- function(x, theta_t_m, theta_t_v, delta_m, delta_v, nu = 1000){
  
  a_i <- get_a_i_cat(x, theta_t_v); a_i
  
  theta_t_m[x] <- theta_t_m[x] + (a_i * delta_m); 
  theta_t_v[x] <- theta_t_v[x] + (a_i^2 * delta_v) + abs(theta_t_m[x])/min(nu, 3000)
  
  return(data.frame(m = theta_t_m, v = theta_t_v))
}


get_a_i_cat <- function(x, theta_t_v){

  return(1 * theta_t_v[x] / sum(1^2 * theta_t_v[x]))
  
  #return(x*(theta_t_v) / sum(x^2 * theta_t_v))
  
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

# 
# 
# 
# 
# 



##################################################
# Trainning


##########
# Variable setting

D <- 2^20 # number of weights

log_loss_adf <- 0
df_log_loss_adf <- data.frame(loss = 0)

# Initial value for mean and variance of theta(parameter)
theta_t_m <- rep(0, D+1)
theta_t_v <- rep(3, D+1)

# Getting gaussian quadrature values.
poly_order <- 10
rule <-hermite.h.quadrature.rules(poly_order)
xxi <- rule[[10]][1]
wwi <- rule[[10]][2]


# DEBUG or not
fl_DEBUG <- TRUE; ts <- ''; ts1 <- ''; ts2 <- '';

# Data file path
#ch_fileName <- "D:/9000_etc/Thesis/data/dac_sample.tar/dac_sample.txt"
#ch_fileName <- "D:/9000_etc/Thesis/data/dac.tar/train.txt"
ch_fileName <- "C:/Temp/dac.tar/train.txt" # file on SSD

conn <- file(ch_fileName, open="r")
li_fiendnames <- c('Label', paste('I', seq(1,13), sep=""), paste('C', seq(1,26), sep="")); li_fiendnames

# Checking running time
ptm <- proc.time()

nu_line <- 0
while(length(oneLine <- readLines(conn, n = 1, warn = FALSE)) > 0 ) {
  nu_line <- nu_line + 1
  ch_oneLine <- paste(oneLine, '\t', sep='') # To deal missing value for end of record.
  ls_oneLine <- unlist(strsplit(ch_oneLine, '\t'))
  
  df_oneLine <- read.table(text="", col.names = li_fiendnames, stringsAsFactors = FALSE)
  df_oneLine <- rbind(df_oneLine, ls_oneLine)
  names(df_oneLine) <- li_fiendnames
  
  
  # Something with df_oneLine
  ts <- df_oneLine
  x_raw <- ts[,-1]; x_raw
  x <- get_mur_x_v3(x_raw); x
  y <- as.numeric(as.character(ts[1,1])); y
  p <- get_p_cat(w, x, FALSE); p
  
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
    print(nu_line)
    print(theta_t_v)
    break()
  }
  
  # Predicted success probability
  p_new <- get_p_cat(x=x, w=theta_t_m, bounded = FALSE)

  # History for mean and variance of theta
  #df_theta_t_m <- rbind(df_theta_t_m, theta_t_m)
  #df_theta_t_v <- rbind(df_theta_t_v, theta_t_v)
  
  # History of logloss
  log_loss_adf <- log_loss_adf + get_logloss(p_new, y)
  df_log_loss_adf <- rbind(df_log_loss_adf, log_loss_adf/nu_line)
  
  
  
  if(nu_line %% 100 == 0) {
    #print(df_oneLine)
    print(paste(nu_line, y, p_new, log_loss_adf/nu_line, sep=', '))
  }
  
  if( nu_line == 10000 ) break;
}
close(conn)
proc.time() - ptm

n_iter <- 10000
plot(seq(1:n_iter), df_log_loss_adf[-1,], type='l')
# 
# 
# 
# 
# 
# df_log_loss_adf[5000,]

# 184.6 sec for 5000 iteration and 0.245 log-loss
# 160.6 sec for 5000 iteration and 0.245 log-loss with MRO w/o MKL(Math Kernel Library)
# 157.8 sec for 5000 iteration and 0.245 log-loss with MRO w/ MKL(Math Kernel Library)
# 3795.6 sec for 100000 iteration and 0.2797 log-loss with MRO w/ MKL(Math Kernel Library)
# 331.19 sec for 10000 iteration and 0.261 log-loss with MRO w/ MKL(Math Kernel Library)

