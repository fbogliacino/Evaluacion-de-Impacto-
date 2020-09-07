clear
set more off
prog drop _all

set obs 200
gen iid=_n
gen W1=runiformint(1,6)
gen W2=runiformint(0,1)
gen D= .5 -.01 * W1 +.12 * W2 + runiform(-.2, +.2)
replace D=1 if D>.5
replace D=0 if D<=.5
gen y = 600 +  1000 * D - 80* W1 + 300* W2 + runiform(-100, 300)

tabstat y if D==1, stat(mean)
tabstat y if D==0, stat(mean)

reg y D 
