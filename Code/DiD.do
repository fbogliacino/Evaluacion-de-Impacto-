cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"

**********************************************************************************
*****************************  Difference in Difference **************************
**********************************************************************************
clear all
set obs 4000 
egen state=seq(), f(1) b(80)
egen iid=seq(), f(1) b(2)
egen time=seq(), f(1) to(2)
bysort state: generate D=runiformint(0,1) if _n==1
bysort state: replace D=D[1] if D==.
gen expost=(time==2)
gen DiD=expost*D

gen outcome=400+ 100*D +600*D*expost - 100 * expost +rnormal(0, 100) 

egen average_outcome=mean(outcome), by(D time)	

graph twoway line average_outcome time if D==1, graphregion(lstyle(none) color(white)) xlabel(1(1)2, labsize(small)) ///
		|| line average_outcome time if D==0, graphregion(lstyle(none) color(white)) ylabel(200(200)1200, labsize(small)) ///
		legend(label(1 "treatment") label (2 "control")) ytitle("outcome") xtitle("Time")
graph export DiD_sketch.png, replace
		
reg outcome D expost DiD, rob
reg outcome D expost DiD, vce(boot, cl(state) reps(99))


tabstat outcome if D==0 & expost==0, stat(mean sd)
tabstat outcome if D==1 & expost==0, stat(mean sd)
tabstat outcome if D==0 & expost==1, stat(mean sd)
tabstat outcome if D==1 & expost==1, stat(mean sd)


**********************************************************************************
*****************************  Card and Krueger **************************
**********************************************************************************

clear all
set obs 410
gen iid=_n
gen state="NJ" if _n<=331
replace state="PA" if state==""
gen empl0=20.4 +rnormal(0, .51) if state=="NJ"
replace empl0=23.3 +rnormal(0, 1.35) if state=="PA"
gen empl1=21.0 +rnormal(0, .52) if state=="NJ"
replace empl1=21.2 +rnormal(0, .94) if state=="PA"
gen wage0=4.61+rnormal(0,.02) if state=="NJ"
replace wage0=4.63+rnormal(0, .04) if state=="PA"
gen wage1=5.08+rnormal(0,.01) if state=="NJ"
replace wage1=4.62+rnormal(0, .04) if state=="PA"
reshape long empl wage, i(iid) j(month)
gen NJ=(state=="NJ")
gen expost=(month==1)
gen NJ_expost=NJ*expost
gen gap=0 if NJ==0
replace gap=0 if NJ==1 & month==0 & wage>=5.05
replace gap=(-wage+5.05)/wage if NJ==1 & month==0 & wage<5.05
bysort iid: replace gap=gap[1] if gap==.
egen empl_punto=mean(empl), by(iid)
egen expost_punto=mean(expost), by(iid)
egen NJ_expost_punto=mean(NJ_expost), by(iid)
gen within_empl=empl-empl_punto
gen within_expost=expost-expost_punto
gen within_NJ_expost=NJ_expost-NJ_expost_punto

reg empl NJ expost NJ_expost, rob
reg within_empl within_expost within_NJ_expost, rob

tsset iid month
xtreg empl expost NJ_expost, fe vce(rob)

gen delta_empl=empl-l.empl
reg delta_empl NJ, rob
reg delta_empl gap, rob

**********************************************************************************
*****************************  BDM **************************
**********************************************************************************

clear all
*set obs 16000
set seed 1234 
prog drop _all

	   program define BDM, rclass
			syntax [, obs(integer 1)]
			drop _all
			set obs `obs'
			tempvar outcome state iid panel time timing u v e
			
egen state=seq(), f(1) b(320)
egen iid=seq(), f(1) b(16)
egen time=seq(), f(1) to(16)
gen panel=1
bysort state: generate D=runiformint(0,1) if _n==1
bysort state: replace D=D[1] if D==.
bysort panel: generate timing=runiformint(4,12) if _n==1
bysort panel: replace timing=timing[1] if timing==.
gen expost=(time>=timing)
gen DiD=D*expost
bysort state: generate u=rnormal(0, 200) if _n==1
bysort state: replace u=u[1] if u==.
bysort iid: generate v=rnormal(0, 200) if _n==1
bysort iid: replace v=v[1] if v==.
bysort iid: generate e=rnormal(0, 200) if _n==1
bysort iid: replace e= .75* e[_n-1] + rnormal(0, 200) if _n>1

scalar beta=0

gen outcome= 400 + 200* expost + beta* D* expost + u + v + e 

reg outcome DiD expost D, rob
			
return scalar pDiD = 2*ttail(e(df_r),abs(_b[DiD]/_se[DiD]))

end

simulate p_DiD=r(pDiD), reps(1000) : BDM, obs(16000) 
gen reject_DiD=p_DiD<0.05
summ reject

clear all
set obs 80000 

egen state=seq(), f(1) b(1600)
egen iid=seq(), f(1) b(8)
egen time=seq(), f(1) to(8)
gen panel=1
bysort state: generate D=runiformint(0,1) if _n==1
bysort state: replace D=D[1] if D==.
bysort panel: generate timing=runiformint(3,6) if _n==1
bysort panel: replace timing=timing[1] if timing==.
gen expost=(time>=timing)
gen DiD=D*expost
bysort state: generate u=rnormal() if _n==1
bysort state: replace u=u[1] if u==.
bysort iid: generate v=rnormal() if _n==1
bysort iid: replace v=v[1] if v==.
bysort iid: generate e=rnormal() if _n==1
bysort iid: replace e= .75* e[_n-1] + rnormal() if _n>1

scalar beta=100

gen outcome= 400 + 200* expost + beta* D* expost + u + v + e 

reg outcome DiD expost D, rob
reg outcome DiD expost D, vce(cl state)
reg outcome DiD expost D, vce(boot, strata(state) reps(99))

cap: drop BDM_outcome
egen BDM_outcome=mean(outcome), by(state expost)
reg BDM_outcome DiD expost D if time>=timing-1 & time<=timing


**********************************************************************************
*****************************  Difference in Difference **************************
**********************************************************************************


clear all
set obs 80000 
egen state=seq(), f(1) b(1600)
egen iid=seq(), f(1) b(8)
egen time=seq(), f(1) to(8)
gen panel=1
bysort state: generate D=runiformint(0,1) if _n==1
bysort state: replace D=D[1] if D==.
bysort state: generate placebo_D=runiformint(0,1) if _n==1
bysort state: replace placebo_D=placebo_D[1] if placebo_D==.
gen expost=(time>4)
gen placebo_expost=(time>=3)
gen DiD=D*expost
gen placebo_DiD=placebo_D*placebo_expost
bysort state: generate u=rnormal(0,300) if _n==1
bysort state: replace u=u[1] if u==.
bysort iid: generate v=rnormal(0,300) if _n==1
bysort iid: replace v=v[1] if v==.
bysort iid: generate e=rnormal(0,300) if _n==1
bysort iid: replace e= .25* e[_n-1] + rnormal(0,300) if _n>1
forval iop=1/8 {
		gen LL`iop'=D*(time==`iop')
		gen d_time`iop'=(time==`iop')
}
drop LL4
drop d_time4

scalar beta=100

gen outcome= 400 + 250* D + 200* expost + beta* D* expost + u + v + e 
gen placebo_outcome= 1500 + 250* D + 350* expost + u + v + e + rnormal(0, 200)

egen average_outcome=mean(outcome), by(D time)	

graph twoway scatter average_outcome time if D==1, graphregion(lstyle(none) color(white)) xlabel(1(1)8, labsize(small)) ///
		|| scatter average_outcome time if D==0, graphregion(lstyle(none) color(white)) ylabel(200(200)500, labsize(small)) ///
		legend(label(1 "treatment") label (2 "control")) ytitle("outcome") xtitle("Time") xline(4.5)
graph export parallel_trend.png, replace

reg outcome d_time* i.state LL*, rob
coefplot ., keep(LL*) yline(0, lcolor(black)) ///
			vertical xline(4, lcolor(black)  lpattern(dot)  lwidth(thick)) ///
			graphregion(lstyle(none) color(white)) ciopts(color(black)) mcolor(black) ///
          xlabel(, labsize(vsmall)) ylabel(, labsize(small)) level(95)
graph export event_study.png, replace
		  
reg outcome DiD D expost, rob
outreg2 using TableDiD, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Treatment Dummy", Yes, "Expost Dummy", Yes, "Standard errors", "Rob") 
reg outcome DiD i.state i.time, rob
outreg2 using TableDiD, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Year FE", Yes, "State FE", Yes, "Standard errors", "Rob") 
tsset iid time
xtreg outcome DiD i.time, fe vce(cl iid)
outreg2 using TableDiD, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster ind") 
erase TableDiD.txt

xtreg outcome DiD i.time, fe vce(cl state)
outreg2 using TableDiD_rob, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster(state)")
xtreg outcome DiD i.time, fe vce(boot, strata(state) reps(99))
outreg2 using TableDiD_rob, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Block Boots") 
cap: drop BDM_outcome
egen BDM_outcome=mean(outcome), by(state expost)
reg BDM_outcome DiD expost i.state if time>=4 & time<=5
outreg2 using TableDiD_rob, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Year FE", Yes, "State FE", Yes, "Standard errors", "Averaged Pre and Post") 
erase TableDiD_rob.txt
			

xtreg outcome placebo_DiD i.time, fe vce(cl state)
outreg2 using TableDiD_placebo, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(placebo_DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster state")
xtreg placebo_outcome DiD i.time, fe vce(cl state)
outreg2 using TableDiD_placebo, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster state")
erase TableDiD_placebo.txt




