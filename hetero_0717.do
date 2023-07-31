





clear
capture log close
set more off



clear
use county_yearbook_finallist

ren 规模以上工业企业单位数 ind_com_no
*ren 规模以上工业总产值 ind_gdp
ren 一般公共预算支出 expenditure
ren 地区生产总值 gdp
ren 户籍人口 pop
ren 居民储蓄存款余额 banking
rename 行政区域面积 area
rename 第一产业增加值 first
rename  农业增加值 arg

gen firstratio=first/gdp
gen argratio=arg/gdp
gen percapita=gdp/pop
gen perarea=area/pop
gen exp=expenditure/gdp
gen popint=pop/area

replace city = subinstr(city, "市", "",.) 
rename period year
keep if year==2019
save hetero_1226.dta,replace


clear

use  outage_ds_0719.dta

rename district county
merge m:1 county using hetero_1226.dta
keep if _merge==3

xtile percapita_lv=percapita, n(3)
xtile exp_lv=exp, n(3)
xtile income_lv=gdp, n(3)
xtile expenditure_lv=expenditure, n(3)
xtile pop_lv=pop, n(3) 
xtile indno_lv=ind_com_no, n(3) 
xtile ind_lv=ind_gdp, n(3) 
xtile banking_lv=banking, n(3)
xtile perarea_lv=banking, n(3)
xtile popint_lv=popint, n(3)
xtile first_lv=first,n(3)
xtile firstratio_lv=firstratio,n(3)
xtile arg_lv=arg,n(3)
xtile argratio_lv=argratio,n(3)

save hetero_2019.dta,replace   

** RUN REGRESSION

clear 
use hetero_2019.dta

xtset ds date
xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
estimates store results1

xtreg llength heatwave i.year i.month $cov1,fe vce(cluster ds)  
estimates store results11
esttab results1 results11, b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)

*local var income_lv
*local var expenditure_lv  
*local var pop_lv 
*local var indno_lv 
*local var banking_lv
*local var exp_lv
*local var percapita_lv 
*local var perarea_lv 
*local var popint_lv 
*local var firstratio_lv 
*local var first_lv  
*expenditure_lv pop_lv indno_lv ind_lv banking_lv
clear 
 foreach m of local var {
 use hetero_2019.dta,clear
keep if `m'==1 
 xtset ds date
 xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results1
 xtreg llength heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results11
 
 use hetero_2019.dta,clear
keep if `m'==2
 xtset ds date
 xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results2
 xtreg llength heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results21

 use hetero_2019.dta,clear
keep if `m'==3
 xtset ds date
 xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results3
 xtreg llength heatwave i.year i.month $cov1,fe vce(cluster ds)  
 estimates store results31

 esttab results1 results2 results3 results11 ///
results21 results31 , b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)
 }
 