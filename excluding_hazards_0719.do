
clear
capture log close
set more off


global cov weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd hazard_economic_loss firetimes holiday
global cov1 weekend IDW_visib IDW_wdsp IDW_prcp IDW_rhmd 


clear
use hazards
sort province city district year month date
quietly by  province city district year month date:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

gen ddate = mdy(month, date, year)
rename date dddate
rename ddate date

save,replace


use hazards.dta,clear
keep if city=="all"
save cityall_hazards,replace

use hazards.dta,clear
keep if district=="all"
save districtall_hazards,replace


clear
use outage_ds_0719.dta,clear

sort province city district date


merge 1:1 province city district  date using hazards.dta
drop if _merge==3
drop if _merge==2
drop _merge

merge m:1 province  date using cityall_hazards.dta
tab _merge
drop if _merge==3
drop if _merge==2
drop _merge

merge m:1 province city date using districtall_hazards.dta
tab _merge
drop if _merge==3
drop if _merge==2
drop _merge

egen dsyear=group(ds year)
xtset ds date

xtreg lnn heatwave i.year i.month $cov,fe vce(cluster ds)  
estimates store results01

xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
estimates store results1

esttab results1 results01 , b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)








