

clear
capture log close
set more off


clear

use station_clean.dta 

xtset station date
tsfill

foreach var of varlist temp visib wdsp prcp rhmd{
bysort station: replace `var'=`var'[_n-1] if `var'==.
}

replace year=year(date) if year==.
replace month=month(date) if month==.

joinby station using distance_1221 

foreach var of varlist temp visib wdsp prcp rhmd{
egen m_`var'=wtmean(`var'), weight(1/distance) by(city year month date)  
rename m_`var' IDW_`var'
}

duplicates drop city date IDW_prcp IDW_rhmd IDW_temp IDW_visib IDW_wdsp,force
drop station

joinby city date using tingdian_district_tsfill.dta 

tab city

duplicates drop ds year month date, force 


** KEEP ONLY SUMMER MONTH
keep if month>=5 & month<=10 

sum IDW_temp,d
return list
gen hightemp=(IDW_temp>r(p90))

gen onedaybefore=hightemp[_n-1] if hightemp==1
gen twodaysbefore=onedaybefore[_n-1] if hightemp==1
order onedaybefore hightemp twodaysbefore
gen heatwave=(hightemp==1 & onedaybefore==1 & twodaysbefore==1)

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


use outage_ds_0719.dta,clear

egen dsyear=group(ds year)

xtset ds date

xtreg lnn heatwave i.year i.month $cov,fe vce(cluster ds)  
estimates store results01

xtreg llength heatwave i.year i.month $cov,fe vce(cluster ds)  
estimates store results02
esttab results01 results02 , b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)


***CITY BY YEAR FIXED EFFECTS


egen cityyear=group(city year)

xtset ds date
xtreg lnn heatwave i.cityyear i.month $cov,fe vce(cluster ds)  
estimates store results1

xtreg llength heatwave  i.cityyear i.month $cov,fe vce(cluster ds) 
estimates store results2
esttab  results1 results2, b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)


**CLUSTER AT CITY LEVEL

xtreg lnn heatwave  i.year i.month $cov,fe vce(cluster city) 
estimates store results30

xtreg llength heatwave i.year i.month $cov,fe vce(cluster city)  
estimates store results31

esttab results30 results31, b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)

** 

use outage_ds_0719.dta,clear
collapse n,by(ds)



***


*** temp increase 

global cov weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd hazard_economic_loss firetimes holiday


gen heatwavetemp=heatwave*IDW_temp
xtset ds date

xtreg lnn heatwavetemp i.year i.month $cov,fe vce(cluster ds) 
estimates store resultstemp1

xtreg llength heatwavetemp  i.year i.month $cov,fe vce(cluster ds) 
estimates store resultstemp2

esttab resultstemp1 resultstemp2 , b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)


*** duration

tsset ds date
tsspell heatwave
bysort ds _spell : gen heatlength = _N
order _spell heatlength _end _seq
replace heatduration=heatlength*heatwave



