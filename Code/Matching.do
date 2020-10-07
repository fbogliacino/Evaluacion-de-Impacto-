cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Do files"
clear
clear matrix
set obs 1000
set seed 1234

gen iid=_n
gen pueblo=runiformint(1,10)
gen female=runiformint(0,1)
gen estrato=runiformint(1,6)
gen puntaje=600*rbeta(2,5)
gen formality=runiformint(0,1)
gen householdsize=runiformint(3,9)
gen subsidio = female + i1.pueblo + i3.pueblo + i5.pueblo + i7.pueblo + i9.pueblo ///
			- i2.pueblo - i4.pueblo - i6.pueblo - i8.pueblo - i10.pueblo ///
			- rbeta(2,5) * puntaje - runiform() * estrato + rnormal() * householdsize + rnormal(0, 10)
egen maxsub=max(subsidio)
egen minsub=min(subsidio)
replace subsidio=(subsidio-minsub) / (maxsub-minsub)
replace subsidio=1 if subsidio>=.8
replace subsidio=0 if subsidio<.8
gen outcome = 500 + i1.pueblo + i3.pueblo + i5.pueblo + i7.pueblo + i9.pueblo ///
			- i2.pueblo - i4.pueblo - i6.pueblo - i8.pueblo - i10.pueblo + formality ///
			+ female + puntaje - householdsize + estrato + 400* subsidio + rnormal(0, 300)
replace outcome=0 if outcome<0

statsmat outcome female puntaje estrato formality householdsize if subsidio==1, stat(mean sd) matrix(balancing_t) 
statsmat outcome female puntaje estrato formality householdsize if subsidio==0, stat(mean sd) matrix(balancing_c) 
mat balancing=balancing_t,balancing_c

foreach varname in outcome female puntaje estrato formality householdsize {
		ttest `varname', by(subsidio)
		mat def `varname'=[r(t), r(p)]
}

mat t_p=[outcome \ female \ puntaje \ estrato \ formality \ householdsize]
mat balancing = balancing, t_p
mat colnames balancing = mean_t sd_t mean_c sd_c t_stat p_value
mat li balancing, f(%5.2f)
outtable using balancing, mat(balancing) f(%5.2f) clabel("" "Mean(T)" "SD(T)" "Mean()" "SD(C)" "T stat" "p()") replace 


probit subsidio female i.pueblo puntaje estrato formality householdsize, vce(rob)
predict propensity_score, pr

graph twoway scatter outcome propensity_score if subsidio==1, graphregion(lstyle(none) color(white)) mcolor(black) ///
		|| scatter outcome propensity_score if subsidio==0, graphregion(lstyle(none) color(white)) mcolor(blue)
graph export outcomepropensity.png, replace		

histogram propensity_score if subsidio==1, percent graphregion(lstyle(none) color(white)) title("Distribution treated")  
graph save subsidio1.gph, replace
histogram propensity_score if subsidio==0, percent graphregion(lstyle(none) color(white)) title("Distribution untreated")		
graph save subsidio0.gph, replace
graph combine subsidio1.gph subsidio0.gph, graphregion(lstyle(none) color(white)) 			
erase subsidio1.gph
erase subsidio0.gph
graph export distribution.png, replace

psmatch2 subsidio female i.pueblo puntaje estrato formality householdsize, outcome(outcome) noreplacement ate common
psmatch2 subsidio female i.pueblo puntaje estrato formality householdsize, outcome(outcome) noreplacement ate trim(20)

psmatch2 subsidio female i.pueblo puntaje estrato formality householdsize, ///
			radius caliper(.10) outcome(outcome) noreplacement ate common
			
psmatch2 subsidio female i.pueblo puntaje estrato formality householdsize, ///
			radius caliper(.10) outcome(outcome) noreplacement ate common
			
psmatch2 subsidio female i.pueblo puntaje estrato formality householdsize, ///
			radius caliper(.10) outcome(outcome) noreplacement ate trim(25)
			
			
teffects psmatch (outcome) (subsidio female i.pueblo puntaje estrato formality householdsize, logit), atet gen(pstub_cps_2) nn(3)
teffects psmatch (outcome) (subsidio female i.pueblo puntaje estrato formality householdsize, logit), atet 

gen puntaje_discretized=.
forval jkl=1/600 {
		replace puntaje_discretized=`jkl' if puntaje>`jkl'-1 & puntaje<=`jkl'  
}
reg outcome subsidio i.pueblo female i.puntaje_discretized i.estrato formality i.householdsize, rob
			
			