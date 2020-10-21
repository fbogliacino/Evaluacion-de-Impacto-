clear all
cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Do files"

set obs 500
set seed 11081980

* generate data

gen X = 100* rbeta(2,5)
gen D=(X>51.4)
gen earnings = 800 + 5* X - 5* 51.4 + 400* D + rnormal(0, 100) 


* plot the data
graph twoway scatter earnings X, xline(51.4) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			xtitle("Puntaje") ytitle("Ingreso per cápita") || lfit earnings X if X<51.4 || lfit earnings X if X>=51.4 
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUN.png", replace

* plot the assignment rule
sort X
graph twoway line D X, lcolor(black) graphregion(lstyle(none) color(white))
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUNsharp.png", replace


* generate the covariate

gen W=50+ X+ rnormal(0, 12)
graph twoway scatter W X, xline(51.4) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			xtitle("Puntaje") ytitle("Covariada") || lfit W X if X<51.4 || lfit W X if X>=51.4
graph save covariada.gph, replace			
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUN.png", replace
graph twoway scatter earnings X, xline(51.4) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			xtitle("Puntaje") ytitle("Ingreso per cápita") || lfit earnings X if X<51.4 || lfit earnings X if X>=51.4 
graph save outcome.gph, replace
graph combine outcome.gph covariada.gph
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\covariadaRDD.png", replace
erase outcome.gph covariadas.gph

* generate counterfactuals

gen D1=1
gen earnings1 = 800 + 5* X - 5* 51.4 + 400* D1 + rnormal(0, 100)
replace earnings1=. if X>51.4
replace earnings1=earnings if X>51.4

gen earnings0 = 800 + 5* X - 5* 51.4 + rnormal(0, 100)
replace earnings0=. if X<=51.4
replace earnings0=earnings if X<=51.4 

* plot the data
graph twoway scatter earnings1 earnings0 X, xline(51.4) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			xtitle("Puntaje") ytitle("Ingreso per cápita")  || lfit earnings1 X || lfit earnings0 X  
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUNcounterfactuals.png", replace
			
* generate nonlinearity

cap: drop earnings2
gen earnings2= 800 - 5* X + 5* 51.4 + .003* (X - 51.4)^3 + rnormal(0, 100)
graph twoway scatter earnings2 X, xline(51.4) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			xtitle("Puntaje") ytitle("Ingreso per cápita") || lfit earnings2 X if X<51.4 || lfit earnings2 X if X>=51.4 ///
			|| fpfit earnings2 X
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUNnonlinear.png", replace


* generate data with self selection into treatment
cap: drop X selfselection
gen X = rnormal(50, 10)
replace X=0 if X<0
replace X=100 if X>100
gen selfselection=runiformint(0,4)
replace X=int(52 + 4*rbeta(2, 5)) if (X<=51 & X>=40) & selfselection==1

hist X, percent graphregion(lstyle(none) color(white)) xline(51.4) bin(50) color(black) fcolor(white)
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\admisionUNmanipulation.png", replace

* generate data to show estimation vs identification

cap: drop X 
cap: drop T 
cap: drop outcome
gen X=runiformint(0, 100)
gen T=(X>51.5)
gen outcome=12+.1*X +5*T+rnormal()
graph twoway scatter outcome X if X>40 & X<70, xline(51.5) graphregion(lstyle(none) color(white)) mcolor(black) legend(off) ///
			mcolor(black) mfcolor(white) xtitle("Running") ytitle("Outcome") ///
			|| lfit outcome X if X>40 & X<51.4 || lfit outcome X if X>=51.4 & X<70  
graph export "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials\appoggioRDD.png", replace
