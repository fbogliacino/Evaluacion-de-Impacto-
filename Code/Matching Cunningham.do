clear all

use https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta, clear
su re78 if treat
gen y1 = r(mean)
su re78 if treat==0
gen y0 = r(mean)
gen ate = y1-y0
su ate
di 6349.144 - 4554.801
* ATE is 1794.34 
drop if treat==0
drop y1 y0 ate
compress

* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
append using https://storage.googleapis.com/causal-inference-mixtape.appspot.com/cps_mixtape.dta
gen agesq=age*age
gen agecube=age*age*age
gen edusq=educ*edu
gen u74 = 0 if re74!=.
replace u74 = 1 if re74==0
gen u75 = 0 if re75!=.
replace u75 = 1 if re75==0
gen interaction1 = educ*re74
gen re74sq=re74^2
gen re75sq=re75^2
gen interaction2 = u74*hisp

* Now estimate the propensity score
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore

* Checking mean propensity scores for treatment and control groups
su pscore if treat==1, detail
su pscore if treat==0, detail

* Now look at the propensity score distribution for treatment and control groups
histogram pscore, by(treat) binrescale



* Trimming the propensity score
drop if pscore <= 0.1 
drop if pscore >= 0.9
teffects ipw (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap) atet
 

* Nearest neighbor matching
cap drop pstub_cps
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), atet gen(pstub_cps) nn(3)


