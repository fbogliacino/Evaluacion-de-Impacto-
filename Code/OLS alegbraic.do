clear
set more off
prog drop _all

set obs 200
gen iid=_n
gen W1=runiformint(1,6)
gen W2=runiformint(0,1)
gen X= 4 + W1 - W2 + runiformint(-4, +4)
replace X=0 if X<0
gen y = 600 +  100 * X - 80* W1 + 300* W2 + rnormal(0, 200)

******* let's show that OLS is just the covariance over the variance
correlate y X, covariance
correlate X X, covariance
reg y X

predict u_i, res
predict y_hat, xb

******* the residuals are orthogonal to prediction and X
correlate y_hat u_i X, covariance

******* the means are on the regression line (plug in the true value)
tabstat X y, stat(mean)
di _b[_cons] + _b[X]* 7.225

******* sum of residual is zero
egen summ_u_i=total(u_i)
summ sum
