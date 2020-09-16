clear
	prog drop _all

	   program define OLS, rclass
			syntax [, obs(integer 1)  ]
			drop _all
			set obs `obs'
			
		scalar beta=800
		scalar alpha=0
		
		gen iid=_n
			
		gen d1=_n>`obs'/2 
	    gen y1= beta*d1 + rnormal(300,1000)
		gen y2= alpha*d1 + rnormal(300,1000)
		reg y1 d1
		return scalar p1= 2*ttail(e(df_r),abs(_b[d1]/_se[d1]))
		return scalar beta1_hat=_b[d1]
		reg y2 d1
		return scalar p2= 2*ttail(e(df_r),abs(_b[d1]/_se[d1]))
		return scalar beta2_hat=_b[d1]
		end

		simulate OLS_beta1=r(beta1_hat) OLS_p1=r(p1) OLS_beta2=r(beta2_hat) OLS_p2=r(p2), reps(1000) : OLS, obs(100)


		hist OLS_beta1, percent graphregion(lstyle(none) color(white)) xline(800) xtitle("Estimated Impact of education") 
		hist OLS_beta2, percent graphregion(lstyle(none) color(white)) xline(0) xtitle("Estimated Impact of blue eyes") normal
			count if OLS_p1<.05
			count if OLS_p2<.05
