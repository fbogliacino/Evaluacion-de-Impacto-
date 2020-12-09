**********************************************************************************
*****************************  Taller V **************************
**********************************************************************************

cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"
clear all
set obs 11200 
set seed 123
egen depto=seq(), f(1) b(350)
egen iid=seq(), f(1) b(10)
egen time=seq(), f(1) to(10)
gen panel=1
bysort depto: generate D=runiformint(0,1) if _n==1
bysort depto: replace D=D[1] if D==.
gen placebo_D=.
forval jkl=1(2)31 {
			replace placebo_D=1 if depto==`jkl'
			replace placebo_D=0 if depto==`jkl' + 1
} 
gen expost=(time>6)
gen placebo_expost=(time>=4)
gen DiD=D*expost
gen placebo_DiD=placebo_D*placebo_expost
bysort depto: generate u=rnormal(0,1) if _n==1
bysort depto: replace u=u[1] if u==.
bysort iid: generate v=rnormal(0,.5) if _n==1
bysort iid: replace v=v[1] if v==.
bysort iid: generate e=rnormal(0,.5) if _n==1
bysort iid: replace e= .9* e[_n-1] + rnormal(0,.5) if _n>1
forval iop=1/10 {
		gen LL`iop'=D*(time==`iop')
		gen d_time`iop'=(time==`iop')
}
drop LL5
drop d_time5

scalar beta=-.5

gen outcome=4.5 +  D + 2* expost + beta* D* expost + u + v + e 

egen average_outcome=mean(outcome), by(D time)	

graph twoway scatter average_outcome time if D==1, graphregion(lstyle(none) color(white)) xlabel(1(1)10, labsize(small)) ///
		|| scatter average_outcome time if D==0, graphregion(lstyle(none) color(white)) ylabel(2(2)8, labsize(small)) ///
		legend(label(1 "treatment") label (2 "control")) ytitle("outcome") xtitle("Time") xline(6.5)
graph export parallel_trend_TallerV.png, replace

reg outcome d_time* i.depto LL*, rob
coefplot ., keep(LL*) yline(0, lcolor(black)) ///
			vertical xline(6, lcolor(black)  lpattern(dot)  lwidth(thick)) ///
			graphregion(lstyle(none) color(white)) ciopts(color(black)) mcolor(black) ///
          xlabel(, labsize(vsmall)) ylabel(, labsize(small)) level(95)
graph export event_study_TallerV.png, replace
		  
reg outcome DiD D expost, rob
outreg2 using TallerV_a, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Treatment Dummy", Yes, "Expost Dummy", Yes, "Standard errors", "Rob") 
reg outcome DiD i.depto i.time, rob
outreg2 using TallerV_a, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Year FE", Yes, "State FE", Yes, "Standard errors", "Rob") 
tsset iid time
xtreg outcome DiD i.time, fe vce(cl iid)
outreg2 using TallerV_a, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster ind") 
erase TallerV_a.txt

xtreg outcome DiD i.time, fe vce(cl depto)
outreg2 using TallerV_b, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster Depto")
xtreg outcome DiD i.time, fe vce(boot, strata(depto) reps(99))
outreg2 using TallerV_b, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Block Boots") 
cap: drop BDM_outcome
egen BDM_outcome=mean(outcome), by(depto expost)
reg BDM_outcome DiD expost i.depto if time>=6 & time<=7
outreg2 using TallerV_b, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(DiD) ///
			symbol(***,**,*) ctitle(OLS) label ///
			addtext("Year FE", Yes, "State FE", Yes, "Standard errors", "Averaged Pre and Post") 
erase TallerV_b.txt
			

reg outcome placebo_DiD placebo_D i.time, vce(cl depto)
outreg2 using TallerV_c, word  ///
			replace dec(2) alpha(0.01, 0.05, 0.1) keep(placebo_DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster state")
xtreg outcome placebo_DiD i.time, fe vce(cl depto)
outreg2 using TallerV_c, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(placebo_DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Cluster state")
xtreg outcome placebo_DiD i.time, fe vce(boot, strata(depto) reps(99))
outreg2 using TallerV_c, word  ///
			append dec(2) alpha(0.01, 0.05, 0.1) keep(placebo_DiD) ///
			symbol(***,**,*) ctitle(FE) label ///
			addtext("Year FE", Yes, "Individual FE", Yes, "Standard errors", "Block boots")
erase TallerV_c.txt




