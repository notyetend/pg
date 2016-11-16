# 
# Generating simulation data for simple logistic regression model likes 'w0 + w1*x'
# and in this test, we will use w0 as 3 and w1 as 10
# and we will assume that x is normalized, so x ~ N(0,1)
# 



#set.seed(1009)
#seed <- .Random.seed
#save(seed, file="tmp.rda")
load("seed.rda")
.Random.seed <- seed


n_iter = 3000

mean_w0 <- 3
mean_w1 <- 10

get_record <- function(){
  w0 <- rnorm(n = 1, mean = mean_w0, sd = 1)
  #w0 <- 2
  w1 <- rnorm(n = 1, mean = mean_w1, sd = 1)
  #w1 <- 5
  #x1 <- runif(n = 1, min = -1, max = 1)
  x1 <- rnorm(n = 1, mean = 0, sd = 1)
  
  s <- w0 + w1*x1
  theta <- 1 / (1 + exp(-s))
  
  y <- rbinom(1, 1, theta)
  
  return(c(w0, w1, x1, s, y))
}

col.names <- c("w0", "w1", "x1", "s", "y")
df <- data.frame(w0=double(), w1=double(), x1=double(), s=double(), y=integer())

for(i in 1:n_iter){
  record <- get_record()
  df <- rbind(df, record)
}
names(df) <- col.names


plot(density(df$w0))
plot(density(df$w1))
plot(density(df$s))


fit <- glm(df$y ~ df$x1, family = "binomial")
summary(fit)





