clear
set more off
prog drop _all

set obs 2000
gen iid=_n
gen D1=_n >_N/2
gen W1=runiformint(1,6)
gen W2=runiformint(0,1)
gen y1 = 100 +  1000 * D1 + 500* W1 + rnormal(0, 500)
gen P= -4 + .6* D1 + .0025*y1 + rnormal(0, 1)
replace P=1 if P>.5
replace P=0 if P<=.5

reg y1 D1, rob
reg y1 D1 P, rob
reg y1 D1 W1 , rob
reg y1 D1 W2, rob


