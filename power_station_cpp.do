clear
capture log close
set more off


use outage_ds_0719,clear
merge m:1 city using city_1227.dta 
keep if _merge==3 
drop _merge

sort ds date
gen id=_n

geonear id latitude longitude using china_cpp.dta, ///
   wide neighbors(trackerid latitude longitude)
   
xtile km_lv=km_to_nid, n(3)

gen heatwavekm=heatwave*km_lv

gen heatwave_km=heatwave*km_to_nid

tab heatwavekm,gen(heatkm)
replace heatwave_km=heatwave_km/100
egen dsyear=group(ds year)
egen cityyear=group(city year)

xtset ds date
xtreg lnn heatwave_km i.year i.month $cov,fe vce(cluster ds) 
estimates store results1


global cov weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd hazard_economic_loss firetimes holiday

xtreg lnn heatwave heatwave_km i.cityyear i.month $cov,fe vce(cluster ds)  
estimates store results11

xtreg llength heatwave_km i.year i.month $cov,fe vce(cluster ds) 
estimates store results2

xtreg llength heatwave heatwave_km i.cityyear i.month $cov1,fe vce(cluster ds) 
estimates store results21

esttab results1 results11 results2 results21, b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)








  