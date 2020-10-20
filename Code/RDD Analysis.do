clear all
cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Do files"

set obs 500
set seed 11081980

* generate data

qui gen X = 100* rbeta(2,5)
qui gen D=(X>51.4)
qui gen earnings = 800 + 5* X - 5* 51.4 + 400* D + rnormal(0, 100) 
qui gen W=50+ X+ rnormal(0, 12)

* Analysis (observen lo que pasa con la constante)
qui cap: drop centered_X
qui gen centered_X=X-51.4
reg earnings D centered_X , rob
reg earnings D X, rob

* qué pasa si usamos regresión lineal en el bandwidth

reg earnings D if X>49 & X<53, rob
reg earnings D if X>45 & X<57, rob
* noten que abriendo los datos la estimación es sesgada
reg earnings D , rob 

* podríamos estimar y=f(X)+ tau D + e_i, usando expansión polinomial de f(X)
* máximo al segundo roden para evitar overfit

qui gen squaredX=X^2-51.4
reg earnings D centered_X squaredX, rob
reg earnings D centered_X squaredX if X>45 & X<57, rob

* podríamos permitir que el polinomio sea diferente a los dos lados
qui gen D_x=centered_X * D
qui gen D_x2=squaredX * D
reg earnings D centered_X squaredX D_x D_x2, rob
* check the confidence interval

* qué pasa si hacemos estimación no paramétrica? ver la slide
qui gen cutoff=51.4
lpoly earnings X, at(cutoff) kernel(rect) bwidth(5) d(2) level(95) n(50) ///
		graphregion(lstyle(none) color(white)) title("Polinomial smooth") xline(51.4) mcolor(black) ///
		lineop(lcolor(red))
*qui cap: gen anchodebanda=X if X>=51.4-5 & X<=51.4+5		
*qui cap: drop pred weight		
*kdensity X, at(anchodebanda) kernel(rect) bwidth(5) gen(pred weight) nograph
*regwls earnings D centered_X squaredX if X>=51.4-5 & X<=51.4+5, wvar(weight) type(e2) rob
rdrobust earnings X, c(51.4) kernel(uniform) h(5) p(2) vce(hc0)

* adding covariates
rdrobust earnings X, c(51.4) kernel(uniform) h(5) p(2) vce(hc0) covs(W)

* data driven bandwidth
rdbwselect earnings X, c(51.4) kernel(uniform) p(2) vce(hc0) covs(W)
rdrobust earnings X, c(51.4) kernel(uniform) h(7.63) p(2) vce(hc0) covs(W)
rdrobust earnings X, c(51.4) kernel(uniform) p(2) vce(hc0) bwselect(mserd) covs(W)

* el mismo tipo de análisis se hace sobre las covariadas para mosrtar ausencia de discontinuidad

*************************************
* las graficas que hay que hacer
*************************************
rdplot earnings X if X>=40 & X<=65, c(51.4)   ///
			kernel(uniform) p(2) nbins(30) support(40 65) ///
			graph_options(graphregion(lstyle(none) color(white)) xtitle("Puntaje") ytitle("Ingreso") legend(off)) 
rdplot earnings X if X>=40 & X<=65, c(51.4)   ///
			kernel(uniform) p(2) nbins(200) support(40 65) ///
			graph_options(graphregion(lstyle(none) color(white)) xtitle("Puntaje") ytitle("Ingreso") legend(off)) 

* probabilidad de tratamiento (sobretodo si fuzzy)		
sort X
graph twoway line D	X, lcolor(black) graphregion(lstyle(none) color(white)) 

* ausencia de discontinuidad

rdplot W X if X>=40 & X<=65, c(51.4)   ///
			kernel(uniform) p(2) nbins(30) support(40 65) ///
			graph_options(graphregion(lstyle(none) color(white)) xtitle("Puntaje") ytitle("Ingreso") legend(off))
			

* visualization of the histogram
hist X, xline(51.4) graphregion(lstyle(none) color(white)) xtitle("Puntaje") ///
		freq fcolor(gs10) lcolor(gs10) width(2) ytitle("Frecuencia")

			
* McCrary test
rddensity X, c(51.4) vce(plugin) plot graph_options(graphregion(lstyle(none) color(white)) xtitle("Puntaje") ytitle("Frecuencia") legend(off))	

* placebo experiment

qui: gen placebo_cutoff= 45
rdplot earnings X if X>=30 & X<=55, c(45) ci(95) shade  ///
			kernel(uniform) p(2) nbins(30) support(40 65) ///
			graph_options(graphregion(lstyle(none) color(white)) xtitle("Puntaje") ytitle("Ingreso") legend(off))

* randomization inference (findit rdlocrand)
rdrandinf earnings X, cutoff(51.4) stat(diffmeans) p(2) cov(W) kernel(uniform) reps(9000) seed(1234)

			
* mecanismos
* aquí depende claramente de qué estamos estudiando, puede ser otro outcome por ejemplo		

* standard errors, either robust or clustering




