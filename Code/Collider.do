cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\slides"
clear all
set obs 1000

gen shooting=rbeta(2,2)
gen clutch=rbeta(2,2)

gen openshoot=.7*shooting + .3 * clutch
egen star=pctile(openshoot), p(90)

graph twoway scatter shooting clutch, legend(off) ytitle("Shooting %") mcolor(black) graphregion(lstyle(none) color(white)) ///
	|| lfit shooting clutch
graph save basket1.gph, replace
graph twoway scatter shooting clutch if openshoot<star, legend(off) ytitle("Shooting %") mcolor(black) graphregion(lstyle(none) color(white)) 
graph save basket2.gph, replace
graph twoway scatter shooting clutch if openshoot>=star, legend(off) ytitle("Shooting %") mcolor(black) graphregion(lstyle(none) color(white)) ///
	|| lfit shooting clutch if openshoot>=star
graph save basket3.gph, replace
graph combine basket3.gph basket2.gph basket1.gph, graphregion(lstyle(none) color(white)) title("Collider Bias")
erase basket1.gph
erase basket2.gph
erase basket3.gph
graph export colliderbiasejemplo1.png, replace


clear all
set obs 10000
* Half of the population is female.
generate female = runiform()>=0.5
* Innate ability is independent of gender.
generate ability = rnormal()
* All women experience discrimination.
generate discrimination = female

* Continuum of occupations ranked monotonically according to ability, conditional
* on discrimination—i.e., higher ability people are allocated to higher ranked
* occupations, but due to discrimination, women are sorted into lower ranked
* occupations, conditional on ability. Also assumes that in the absence of
* discrimination, women and men would sort into identical occupations (on average).

generate occupation = (1) + (2)*ability + (0)*female + (-2)*discrimination + rnormal()

*The wage is a function of discrimination even in identical jobs, occupational
* choice (which is also affected by discrimination) and ability.

generate wage = (1) + (-1)*discrimination + (1)*occupation + 2*ability + rnormal()

* Assume that ability is unobserved. Then if we regress female on wage, we get a
* a consistent estimate of the unconditional effect of discrimination— i.e.,
* both the direct effect (paying women less in the same job) and indirect effect
* (occupational choice).
regress wage female
outreg2 using TableCollider, word replace dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Unconditional)

* But occupational choice is correlated with the unobserved factor ability *and*
* it is correlated with female, so renders our estimate on female and occupation
* no longer informative.

regress wage female occupation
outreg2 using TableCollider, word append dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Collider)

* Of course, if we could only control for ability...

regress wage female occupation ability
outreg2 using TableCollider, word append dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Identified)
			
			
			
			
******** Collider Bias, example from Cunningham

clear all
set seed 541
* Creating collider bias
* Z -> D -> Y
* D ->X <- Y
* 2500 independent draws from standard normal distribution
clear
set obs 2500
gen z = rnormal()
gen k = rnormal(10,4)
gen d = 0
replace d =1 if k>=12
* Treatment effect = 50. Notice y is not a function of X.
gen y = d*50 + 100 + rnormal()
gen x = d*50 + y + rnormal(50,1)
* Regression
reg y d, robust
outreg2 using TableCollider2, word replace dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Identified)
reg y x, robust
outreg2 using TableCollider2, word append dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Collider)
reg y d x, robust
outreg2 using TableCollider2, word append dec(2) alpha(0.01, 0.05, 0.1) ///
			symbol(***,**,*) ctitle(Biased)			
