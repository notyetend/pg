# 
# Comparison plots for gd and adf.
# 
# 
# 




#ML Estimate
fit$coefficients[1]


## w0
# With Gradient descent
sq <- seq(1:n_iter); sqn <- sq[sq %% 50 == 0]

plot(seq(1:n_iter), df_w[-1,]$w0, type='l', ylim=c(0,mean_w0*1.6), col="Blue", xlab = "Iteration", ylab = "w_0", lty = 5)
#points(sqn, df_w[-1,][sqn,]$w0, pch = 3)
abline(h=fit$coefficients[1], b=0, col="Black", lty=2)
# With ADF
lines(seq(1:n_iter), df_theta_t_m[-1,]$m0, type='l', col="Red")
#points(sqn, df_theta_t_m[-1,][sqn,]$m0, pch = 4)
legend(2450, 0.9, c("MLE", "GD", "ADF"), lty=c(3, 1, 1), lwd=c(2.5,2.5), col=c("Black", "Blue", "Red"), bty='n', cex=0.75)


## w1
# With Gradient descent
plot(seq(1:n_iter), df_w[-1,]$w1, type='l', ylim=c(0,mean_w1*1.2), col="Blue", xlab = "Iteration", ylab = "w_1", lty = 5)
abline(h=fit$coefficients[2], b=0, col="Black", lty=2)
# With ADF
lines(seq(1:n_iter), df_theta_t_m[-1,]$m1, type='l', col="Red")
legend(2500, 3, c("MLE", "GD", "ADF"), lty=c(3, 1, 1), lwd=c(2.5,2.5), col=c("Black", "Blue", "Red"), bty='n', cex=0.75)


## loss
# With Gradient descent
plot(seq(1:n_iter), df_w[-1,]$loss, type='l', col="Blue", ylim=c(0.13, 0.65), xlab = "Iteration", ylab = "log loss / iteration")
# With ADF
lines(seq(1:n_iter), df_loss[-1,], type='l', col="Red")
legend(2500, 0.60, c("GD", "ADF"), lty=c(1,1), lwd=c(2.5,2.5), col=c("Blue", "Red"), bty='n', cex=0.75)


c(df_w[200,]$loss, df_loss[200,])
c(df_w[500,]$loss, df_loss[500,])
c(df_w[1500,]$loss, df_loss[1500,])
c(df_w[3000,]$loss, df_loss[3000,])
