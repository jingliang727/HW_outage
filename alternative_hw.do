




clear
capture log close
set more off

use station_1921.dta,clear

gen ddate=date(date,"YMD")
drop date
rename ddate date
gen year=year(date)
gen month=month(date)

keep temp dewp stp visib wdsp prcp year month date station max

replace dewp=. if dewp>9999.9
replace stp=. if stp>9999.9
replace visib=. if visib>999.9
replace wdsp=. if wdsp>999.9
replace max=. if max>999
replace prcp=. if prcp>999
replace max=(max-32)*5/9 //originally F, convert to C
replace temp=(temp-32)*5/9 
replace dewp=(dewp-32)*5/9 //originally F, convert to C
replace wdsp=wdsp*0.5144 

gen rhmd=100*(exp((17.625*dewp)/(243.04+dewp))/exp((17.625*temp)/(243.04+temp)))
save station_clean_0407.dta,replace

****

clear
use station_clean_0407.dta 

xtset station date
tsfill

foreach var of varlist max temp visib wdsp prcp rhmd{
bysort station: replace `var'=`var'[_n-1] if `var'==.
}

replace year=year(date) if year==.
replace month=month(date) if month==.

joinby station using distance_1221 

foreach var of varlist temp visib wdsp prcp rhmd max{
egen m_`var'=wtmean(`var'), weight(1/distance) by(city year month date) 
drop `var'
rename m_`var' IDW_`var'
}

duplicates drop city date IDW_prcp IDW_max IDW_rhmd IDW_temp IDW_visib IDW_wdsp,force
drop station

joinby city date using tingdian_district_tsfill.dta

save joint2_0408.dta,replace



use joint2_0408.dta,clear
duplicates drop ds year month date, force 

sum IDW_temp,d
return list
 
gen hightemp=(IDW_max>35)
order hightemp
sort city date 
gen onedaybefore=hightemp[_n-1] if hightemp==1
gen twodaysbefore=onedaybefore[_n-1] if hightemp==1
order onedaybefore hightemp twodaysbefore
gen heatwave=(hightemp==1 & onedaybefore==1 & twodaysbefore==1)
order heatwave



replace n=n+1
replace length=length+1

gen lnn=ln(n)
gen llength=ln(length)
gen weekofday=dow(date)
gen weekend=(weekofday==6 | weekofday==0)

merge m:1 province year using zaihai_fire.dta
drop if _merge==2

global cov weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd hazard_economic_loss firetimes holiday
global cov1 weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd 

drop _merge
merge m:1 date using holiday.dta
replace holiday=0 if holiday==.
drop _merge
** drop SUMMER
keep if month>=5 & month<=10
save alt_ds_0719.dta,replace

*** RUN REGRESSION


xtset ds date
xtreg lnn heatwave i.year i.month $cov,fe vce(cluster ds)  
estimates store results01

xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
estimates store results1
esttab results1 results01 , b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)

