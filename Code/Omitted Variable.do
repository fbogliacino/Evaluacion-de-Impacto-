cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"
clear all
 set obs 1000
 gen x1=runiformint(1, 6)
 gen x2=runiformint(0,1)
 gen ability=runiformint(0,1)
 gen x3=.2 * x1 + .05 * x2 + .15 * ability + rnormal(0,1)
 replace x3=1 if x3>.5
 replace x3=0 if x3<=.5
 gen u=rnormal(0, 100)
 gen y= 500 +100 * x1 + 100* x2 + 100* x3 + 200 * ability + u 
 
 reg y x3
 
 reg y x1 x2 x3 ability
 scalar unbiasedS=_b[x3]
 scalar unbiasedA=_b[ability]
 
 reg y x1 x2 x3
 scalar biased=_b[x3]
 
 reg ability x1 x2 x3  
 scalar covAS=_b[x3]
 
 di unbiasedS + covAS*unbiasedA
 di biased
