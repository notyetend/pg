# Simulation for the gradient descent
# 
# 
# 
# 
# 
# 
# 



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


# 
# Function for update w with simle gradient descent having fixed alpha
# 
# I don't know yet or forgot why formula looks like this...
# (p-y)*x ... Is this 1st order differential equation of logistic formula?
update_w <- function(w, x, p, y, nu = 1000){  
  w <- w - (p - y)*x * alpha
  return(w)
}




alpha = c(0.08, 1.1)
w <- c(0, 0)
df_w <- data.frame(w0 = 0, w1 = 1, loss = 0)
n <- nrow(df)
df[1,]$x1


loss_gd <- 0
for( i in 1:n ){
  xi <- c(1, df[i,]$x1)
  yi <- df[i,]$y
  
  p <- get_p(xi, w, FALSE)
  w <- update_w(w, xi, p, yi, i)
  
  p_new <- get_p(xi, w, FALSE)
  loss_gd <- loss_gd + get_logloss(p_new, yi)
  
  
  df_w <- rbind(df_w, c(w, loss_gd/i))
}

summary(fit)
w

# Progress of w0 and ML fit value
plot(seq(1:n), df_w[-1,]$w0, type='l')
abline(h=mean_w0, b=0, col="Blue", lty=2)

# Progress of w1 and ML fit value
plot(seq(1:n), df_w[-1,]$w1, type='l')
abline(h=mean_w1, b=0, col="Blue", lty=2)

# Progress of logloss
plot(seq(1:n), df_w[-1,]$loss, type='l')

tail(df_w$loss)
