# 
# Simulation for the ADF(Assumed Density Filtering)
# 
# 
# 
# 
# 


# Package for gaussian quadrature
#install.packages("gaussquad")
library(gaussquad)

# Getting gaussian quadrature values.
poly_order <- 10
rule <-hermite.h.quadrature.rules(poly_order)
xxi <- rule[[10]][1]; xxi
wwi <- rule[[10]][2]; wwi



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





get_a_i <- function(x, theta_t_v){
  return(x*(theta_t_v) / sum(x^2 * theta_t_v))
}




update_theta <- function(x, theta_t_m, theta_t_v, delta_m, delta_v, nu = 1000){
  a_i <- get_a_i(x, theta_t_v)
  #theta_t_v <- theta_t_v + (a_i^2 * delta_v) + abs(theta_t_m)/min(nu, 3000)
  theta_t_m <- theta_t_m + (a_i * delta_m)
  theta_t_v <- theta_t_v + (a_i^2 * delta_v) + abs(theta_t_m)/min(nu, 3000)
  
  return(data.frame(m = theta_t_m, v = theta_t_v))
}




# Function for calculate success probability of logistic model.
# Param 1: x vector
# Param 2: w vector(beta)
# Output : success probability of logistic model
get_p <- function(x, w, bounded = FALSE){
  wTx <- sum(x*w)
  bounded_wTx <- max( min(wTx, 10),-10 )
  
  if( bounded ){
    return(1 / (1+exp(-bounded_wTx)))
  } else{
    return(1 / (1+exp(-wTx)))
  }
}




# c(2/3000, 5/3000)
# c(0.0004, 0.0008)
# ts_theta_m <- c(2, 3)
# ts_theta_v <- c(1, 1)
# ts_delta_m <- 5
# ts_delta_v <- 3
# ts_x <- c(1, 3)
# update_theta(ts_x, ts_theta_m, ts_theta_v, ts_delta_m, ts_delta_v)


# Initial value for mean and variance of theta(parameter)
theta_t_m <- c(0, 0)
theta_t_v <- c(1, 1)

df_theta_t_m <- data.frame(m0 = 0, m1 = 0)
df_theta_t_v <- data.frame(v0 = 1, v1 = 1)
df_loss <- data.frame(loss = 0)


loss_adf <- 0
for( i in 1:n_iter ){
  
  #i <- 2
  
  xi <- c(1, df[i,]$x1); xi
  yi <- df[i,]$y; yi
  
  # Predictive distribution for s_t ~ N(s_t_m_old, s_t_v_old)
  s_t_m_old <- sum(theta_t_m * xi); s_t_m_old
  s_t_v_old <- sum(theta_t_v * (xi^2)); s_t_v_old
  
  # Posterior distribution for s_t
  s_t_new <- get_s_t_new(yi, s_t_m_old, s_t_v_old)
  s_t_m <- s_t_new[1]
  s_t_v <- s_t_new[2]
  
  # Changes in s_t
  delta_m <- s_t_m - s_t_m_old
  delta_v <- s_t_v - s_t_v_old
  
  # Updating theta
  theta_t <- update_theta(xi, theta_t_m, theta_t_v, delta_m, delta_v, i)
  theta_t_m <- theta_t$m; theta_t_m
  theta_t_v <- theta_t$v; theta_t_v
  
  # Predicted success probability
  p_new <- get_p(x=xi, w=theta_t_m, bounded = FALSE)
  loss_adf <- loss_adf + get_logloss(p_new, yi)
  
  # History for mean and variance of theta
  df_theta_t_m <- rbind(df_theta_t_m, theta_t_m)
  df_theta_t_v <- rbind(df_theta_t_v, theta_t_v)
  
  # History of logloss
  df_loss <- rbind(df_loss, loss_adf/i)
}

summary(fit)
theta_t_m
theta_t_v

plot(seq(1:n_iter), df_theta_t_m[-1,]$m0, type='l')
abline(h=mean_w0, b=0, col="Blue", lty=2)

plot(seq(1:n_iter), df_theta_t_m[-1,]$m1, type='l')
abline(h=mean_w1, b=0, col="Blue", lty=2)

plot(seq(1:n_iter), df_theta_t_v[-1,]$v0, type='l')
plot(seq(1:n_iter), df_theta_t_v[-1,]$v1, type='l')

plot(seq(1:n_iter), df_loss[-1,], type='l')

tail(df_loss)




# 2996 0.2487992
# 2997 0.2487668
# 2998 0.2486844
# 2999 0.2486974
# 3000 0.2486640
# 3001 0.2489879