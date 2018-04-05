/* Question 1 */

ods noproctitle;
ods graphics / imagemap=on;

proc means data=EUROPET.EUROPET chartype mean std min max n vardef=df;
	var Sales TV Radio 'Fuel Volume'n;
run;


/* Question 2 */

ods noproctitle;
ods graphics / imagemap=on;

proc reg data=EUROPET.EUROPET alpha=0.05 plots(only)=(diagnostics residuals 
		fitplot observedbypredicted);
	model Sales='Fuel Volume'n /;
	run;
quit;

/* Conclusion:
- At a 95% confidence level, there is a statistically significant relationship 
between sales and fuel volume because the p-value of the coefficient estimate 
on fuel volume is < 0.0001.
- Estimates for average sales in the data sets for weeks when fuel volume levels
were at the smallest, average, and largest observed value, respectively:
	+ With the smallest fuel volume = 56,259,
	average sales = -17490 + 0.64521 * 56,259 = $18,808.86
	+ With mean fuel volume = 62,852.76, 
	average sales = -17490 + 0.64521 * 62,852.76 = $23,063.22
	+ With the largest fuel volume = 68,549,
	average sales = -17490 + 0.64521 * 68,549 = $26,738.50
- There is a significant causal relationship between sales and fuel volume.
1 liter increase in fuel volume leads to $0.64521 increase in sales.
*/


/* Question 3 */

ods noproctitle;
ods graphics / imagemap=on;

proc reg data=EUROPET.EUROPET alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model Sales=TV Radio /;
	run;
quit;

/* Conclusion:
- At the 95% confidence level, TV has a statistically significant effect on sales,
while Radio doesn't.
- Estimate for sales for a week with 40 TV GRPs and 80 radio GRPs:
sales = 22142 + 12.19268 * 40 + 5.19530 * 80 = $23,045.33
- At any level of fuel volume, advertising spending on 40 TV GRPs and 
80 radio GRPs boosts sales revenue by $23,045.33. The cost of running 40 TV GRPs 
and 80 radio GRPs = 40 * 300 + 80 * 25 = $14,000. Therefore, advertising spending
contributes $23,045.33 - $14,000 = $9,045.33 in profit. In other words, advertising
spending sufficiently boosts sales.
*/


/* Question 4 */

ods noproctitle;
ods graphics / imagemap=on;

proc reg data=EUROPET.EUROPET alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	model Sales=TV Radio Temp /;
	run;
quit;

/* Conclusions:
- It is clear that the regression model in Question 3 suffers from 
omitted variable bias. By including the Temp variable in the regression model 
in Question 4, the coefficient estimate on Temp is statistically significant 
with a p-value of < 0.0001, and the coefficient estimates and standard errors 
on TV and Radio decrease.
- Because TV, Radio, and Temp are all statistically significant at the threshold 
of 10% significance level, they should be kept in the regression model. Based on 
this regression, estimate for sales for a week with 40 TV GRPs and 80 radio GRPs 
= 19190 + 11.29750 * 40 + 0.16463 * 80 = $19,655.07. The cost of running 40 TV GRPs 
and 80 radio GRPs = 40 * 300 + 80 * 25 = $14,000. Therefore, advertising spending 
contributes $19,655.07 - $14,000 = $5,655.07 in profit. In other words, advertising 
spending still sufficiently boosts sales even when we control for the weather.
- What needs to be true in order for the coefficients in the regression for 
advertising to be profitable:
	+ Assuming all else equal
	+ The marginal contribution to sales revenue > the cost of advertising 
	($14,000)
*/


/* Question 5 */

/*** All variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET outdesign(addinputvars)=Work.reg_design;
	class Holiday / param=glm;
	model Sales=TV Radio 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/*** Selected variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET outdesign(addinputvars)=Work.reg_design;
	class Holiday / param=glm;
	model Sales=TV 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/* Conclusion
- At the 10% significance level, the variables with p-value < 0.1 will be dropped.
Final regression equation: sales = -2849.941071 + 5.594468 * TV 
+ 0.279107 * fuel volume + 85.177198 * fuel price + 68.935033 * temp 
- 138.504267 * prec - 157.251236 * visits - 895.257950 * holiday0
- Although advertising spending (TV) is statistically significant, its effect 
on sales revenue is very small compared to the effect of other factors in the 
regression.
- The effect of fuel volume is the smallest because quantity available for sale 
does not affect customers’ buying decisions.
- The effect of fuel price is large and positive because it’s one of the 
accounting determinants of sales revenue.
- The effect of temp is also large and positive, suggesting that the higher 
the temperature, the more likely people spend time outside or travel, and 
the more likely they go to convenience stores to buy a snack or a drink.
- The effect of precipitation is large and negative, suggesting that the harder 
it rains, the more likely people spend time indoors and will unlikely need to 
go to a convenience store.
- The effect of visits is large and negative, suggesting that the greater the 
percentage of customers who visit the store 1-2 times/week, the lower the sales 
revenue. Although this insight is counter-intuitive, it might suggest that sales 
revenue would be positively driven if the majority of the customers visit the 
stores more often than 1-2 times/week.
- The effect of having no holidays is large and negative because people don’t 
travel during they don’t have holidays, reducing the need to go to a convenience 
store when they just go about their daily routine.
- If TV GRPs increases by 5 rating points (units), sales will increase by 
5 * 5.594468 = $27.97.
	+ 95% confidence interval: 5 * (5.594468 +/- 1.96 * 1.635050) 
	= 5 * (2.38977; 8.799166) = (11.94885; 43.99583)
- Based on this regression, sales revenue boosted by 40 TV GRPs of advertising 
= 5.594468 * 40 = $223.77. The cost of running 40 TV GRPs and 80 radio GRPs 
= 40 * 300 + 80 * 25 = $14,000. Therefore, advertising spending contributes 
$223.77 - $14,000 = -13776.22in profit. In other words, advertising spending is 
no longer sufficient in helping boost sales revenue.
*/


/* Question 6 */

/*** Create dummy variables for weeks 7, 21, 49 ***/
data europet.europet_new;
	set europet.europet;
	if week=7 then week7=1;
	else week7=0;
	if week=21 then week21=1;
	else week21=0;
	if week=49 then week49=1;
	else week49=0;
run;

/*** Build regression model on all variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET_NEW outdesign(addinputvars)=Work.reg_design;
	class Holiday week7 week21 week49 / param=glm;
	model Sales=TV Radio 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday week7 week21 week49 / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing and week7 is not missing and week21 is not 
		missing and week49 is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/*** Build regression model on selected variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET_NEW outdesign(addinputvars)=Work.reg_design;
	class Holiday week7 week21 week49 / param=glm;
	model Sales=TV 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday week7 week21 week49 / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing and week7 is not missing and week21 is not 
		missing and week49 is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/* Conclusion:
- At the 10% significance level, the variables with a p-value > 0.1 will be 
dropped from the regression equations. The final regression equation is sales 
= - 1569.974095 + 6.033844 * TV + 0.306204 * fuel volume + 81.567558 * fuel price 
+ 57.787306 * temp - 131.712777 * prec - 180.426131 * visits 
- 989.613604 * holiday0 + 1821.985693 * week70 - 2045.993325 * week210 
- 2102.041187 * week490
- The coefficients of the new dummy variables are statistically significant. 
The new R-squared is 0.8781.
- These new dummy variables represent weeks with heavy travels. Week 7 is around 
Valentine’s day, week 21 graduation season, and week 49 Thanksgiving holiday. 
The dummy variables control for the effect of seasonal travels that increase 
the likelihood of customers going to convenience stores.
- If the goal of the regression model is to make predictions on future sales, 
then increasing the R-squared of the current regression built on historical data 
does guarantee better prediction power because we might overfit the model and 
fail to generalize when making predictions on unseen data.
- However, if the goal of the regression model is to measure the causal effect 
of advertising spending on sales, then it’s important to include the dummy 
variables to control for the effect of seasonality, which will yield a better 
coefficient estimate on advertising variables.
*/


/* Question 7 */

ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET outdesign(addinputvars)=Work.reg_design;
	class Holiday / param=glm;
	model Sales=TV Radio 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday TV*Holiday Radio*Holiday / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/* Conclusion:
- By adding the interaction terms between advertising spending and holiday, 
the new regression output shows statistically insignificant coefficient estimates 
on TV (p-value = 0.1777), Radio (p-value = 0.7039), TV*Holiday0 (p-value = 0.6787), 
and Radio*Holiday0 (p-value = 0.8491), at the 10% significance level.
- Therefore, TV and radio advertising don’t have a significantly larger influence 
on sales in weeks without holidays than in holiday weeks.
*/


/* Question 8 */

/*** All variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET outdesign(addinputvars)=Work.reg_design;
	class Holiday / param=glm;
	model Sales=TV 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Holiday Temp*Holiday / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/*** Selected variables ***/
ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=EUROPET.EUROPET outdesign(addinputvars)=Work.reg_design;
	class Holiday / param=glm;
	model Sales=TV 'Fuel Volume'n 'Fuel Price'n Temp Prec 'Visits (1 or 2)'n 
		Temp*Holiday Holiday / showpvalues selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	where Holiday is not missing;
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Sales=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/* Conclusion:
- At the 10% significance level, all the variables with a p-value > 0.1 will be 
dropped. The final regression equation is sales = - 1467.338615 + 5.730813 * TV 
+ 0.283054 * fuel volume + 78.381199 * fuel price + 36.771750 * temp 
- 149.538694 * prec - 176.987617 * visit - 2192.018106 * holiday0 
+ 76.799947 * Temp*Holiday0
- Because the coefficient estimate on temp*holiday0 is large, positive, and 
statistically significant at the 10% significance level, temperature has a 
significantly stronger effect on sales in weeks without a holiday than in weeks 
with a holiday.
*/


/* Question 9 */

/* Conclusion:
- The economic effectiveness of advertising is low. In all of the regression 
equations above, although the coefficient on advertising spending is 
statistically significant at the 10% significance level, the magnitude of the 
coefficient estimate is low. TV has a larger effect on sales than radio does.
- Meanwhile, the coefficient estimates on other weather factors are statistically 
significant at the 10% significance level and have greater magnitude.
- EuroPet should discontinue the advertising campaigns. Even if this decision is 
implemented, the company won’t see a drastic decrease in sales as a result.
*/
