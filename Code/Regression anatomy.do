cd "C:\Users\franc\Dropbox\Nacho\Didactica\Evaluación de impacto\2020 II\Materials"
clear all
 set obs 1000
 gen x1=runiformint(1, 6)
 gen x2=runiformint(0,1)
 gen x3=.2 * x1 + .05 * x2 + rnormal(0,1)
 replace x3=1 if x3>.5
 replace x3=0 if x3<=.5
 gen u=rnormal(0, 500)
 gen y= 500 +100 * x1 + 100* x2 + 100* x3 + u 
 
 reg y x3
 reg y x1 x2 x3
 
 reg x3 x1 x2
 predict e_x3, res
 
 reg y e_x3
 
 
 