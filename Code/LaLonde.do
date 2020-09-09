clear all
* insert current directory
*cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"

use "LaLonde NSW sample.dta"

gen agesq=age^2
reg re75 treat, rob
reg re75 treat age agesq educ nodegree black hisp, rob
reg re78 treat, rob
reg re78 treat age agesq educ nodegree black hisp, rob

gen did=re78-re75
reg did treat, rob
reg did treat age, rob

reg re78 re75 treat, rob 
reg re78 treat re75 age agesq educ nodegree black hisp, rob




