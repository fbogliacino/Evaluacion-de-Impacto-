clear all
clear matrix
cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"
use "LaLonde NSW sample.dta"

tabstat re78 if treat==1, stat(mean)
tabstat re78 if treat==0, stat(mean)

di 6349.144-4554.801
reg re78 treat
reg re78 treat, rob

**** vamos al excel RI un segundo

ritest treat _b[treat], reps(1000) seed(123): reg re78 treat, rob
ritest treat _b[treat], reps(1000) kdensityplot seed(123): reg re78 treat, rob

** cuántas son las combinaciones?
** tengo 445 observaciones, 185 tratados
** 445!/(445-185)!185!= un número espantoso
** por esto se hace simulación, controlando por el seed para replicar

tabstat re78 if treat==1 & re75==0, stat(mean)
tabstat re78 if treat==0 & re75==0, stat(mean)
tabstat re78 if treat==1 & re75>0, stat(mean)
tabstat re78 if treat==0 & re75>0, stat(mean)
reg re78 treat if re75==0, rob
reg re78 treat if re75!=0, rob

*treatment effect
di 156/445 * 1691.381 + 289/445 * 1711.402
gen noprior=(re75!=0)
reg re78 treat noprior, rob 

* en general podemos definir dummies para celdas


*********** balancing of covariates
statsmat age educ black hisp marr nodegree if treat==1, stat(mean sd) matrix(balancing_t) 
statsmat age educ black hisp marr nodegree if treat==0, stat(mean sd) matrix(balancing_c) 
mat balancing=balancing_t,balancing_c

foreach varname in age educ black hisp marr nodegree {
		ttest `varname', by(treat)
		mat def `varname'=[r(t), r(p)]
}

mat t_p=[age \ educ \ black \ hisp \ marr \ nodegree]
mat balancing = balancing, t_p
mat colnames balancing = mean_t sd_t mean_c sd_c t_stat p_value
mat li balancing, f(%5.2f)
outtable using balancing, mat(balancing) f(%5.2f) clabel("" "Mean(T)" "SD(T)" "Mean()" "SD(C)" "T stat" "p()") replace 



******* one nice table with regression

				*cap n tempvar tempsample
				*cap n local specname=`specname'+1

				* Column 1: No covariates
				cap n reg re78 treat, robust
				cap n estimates store nocov
				cap n estadd ysumm


				* Column 2: Covariates
				cap n reg re78 treat age educ black hisp marr nodegree, robust
				cap n estimates store sicov
				cap n estadd ysumm


#delimit ;
	cap n estout * using ./nsw.tex,
		style(tex) label notype
		cells((b(star fmt(%9.3f))) (se(fmt(%9.3f)par))) 		
		stats(N ymean,
			labels("N" "Mean of dependent variable")
			fmt(%9.0fc %9.2fc 2))
			drop(_cons) 
			replace noabbrev starlevels(* 0.10 ** 0.05 *** 0.01) 
			title(OLS estimates of effect of NSW on Earnings)   
			collabels(none) eqlabels(none) mlabels(none) mgroups(none) substitute(_ \_)
			prehead("\begin{table}[htbp]\centering" "\small" "\caption{@title}" "\begin{center}" "\begin{threeparttable}" "\begin{tabular}{l*{@E}{c}}"
	"\toprule" "\hline"
	"\multicolumn{1}{l}{\textbf{Dependent variable: Earnings}}&" 
	"\multicolumn{1}{c}{\textbf{(1)}}&"
	"\multicolumn{1}{c}{\textbf{(2)}}\\")
		posthead("\midrule")
		prefoot("\midrule")  
		postfoot("\bottomrule" "\hline" "\end{tabular}" "\begin{tablenotes}" "\tiny" "\item Data is from NSW.  Heteroskedastic standard errors shown in parenthesis.  * p$<$0.10, ** p$<$0.05, *** p$<$0.01" "\end{tablenotes}" "\end{threeparttable}" "\end{center}" "\end{table}");
#delimit cr
	cap n estimates clear

reg re78 treat, robust
outreg2 using Table, word replace
reg re78 treat age educ black hisp marr nodegree, robust
outreg2 using Table, word append	
	