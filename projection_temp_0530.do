

log close
log using projection_0530.smcl,replace


use outage_ds_0504.dta,clear
merge m:1 city using city_1227.dta // get lat and long for cities 
keep if _merge==3 
drop _merge


save city_latlon_projection_0530.dta,replace



***rcp 26 

foreach x of numlist 2090  {

 import delimited "C:\ts_all_`x'_`x'_rcp26\ts_all.txt", clear 


 sort lat lon
 
 gen id=_n
 
 forvalues i=3/14 {
 	local j=`i'-2
	replace  v`i' = v`i' -273.15
 	rename v`i' month`j'
 }
 
 drop v15
 
 
 reshape long month,i(id) j(j)
 ren month rcp26_`x'
 gen year=`x'
 ren j month
 
 save rcp26_`x'.dta,replace  
 
 
  use rcp26_2020,clear
 
 merge 1:1 lat lon month using rcp26_`x'.dta  
 
  gen change=rcp26_`x'-rcp26_2020
 
 keep id month change lat lon
 save change_`x'.dta,replace
 
 
  use city_latlon_projection_0530.dta
  geonear city latitude longitude using change_`x'.dta, ///
   wide neighbors(id lat lon)

     rename nid id
   
   sort id month

   merge m:1 id month using change_`x'.dta
 keep if _merge==3
 drop _merge
 

 gen newtemp=IDW_temp+change
 
 
 drop hightemp onedaybefore twodaysbefore heatwave 
 
  sum newtemp,d
  return list
 
*gen hightemp=(newtemp>r(p90))
 gen hightemp=(newtemp>27.66)
order hightemp

sort city date 

gen onedaybefore=hightemp[_n-1] if hightemp==1
gen twodaysbefore=onedaybefore[_n-1] if hightemp==1

order onedaybefore hightemp twodaysbefore

gen heatwave=(hightemp==1 & onedaybefore==1 & twodaysbefore==1)
order heatwave
tab heatwave

save ht_`x'.dta,replace

 sum heatwave  
 
}
 
 
 
 ** 4.5

foreach x of numlist 2030 2050 2090 {

 import delimited "\ts_all_`x'_`x'_rcp45\ts_all.txt", clear 


 sort lat lon
 
 gen id=_n
 
 forvalues i=3/14 {
 	local j=`i'-2
	replace  v`i' = v`i' -273.15
 	rename v`i' month`j'
 }
 
 drop v15
 
 
 reshape long month,i(id) j(j)
 ren month rcp26_`x'
 gen year=`x'
 ren j month
 
 save rcp26_`x'.dta,replace  
 
 
  use rcp26_2020,clear
 
 merge 1:1 lat lon month using rcp26_`x'.dta  
 
  gen change=rcp26_`x'-rcp26_2020
 
 keep id month change lat lon
 save change_`x'.dta,replace
 
 
  use city_latlon_projection.dta
  geonear city latitude longitude using change_2030.dta, ///
   wide neighbors(id lat lon)

     rename nid id
   
   sort id month

   merge m:1 id month using change_`x'.dta
 keep if _merge==3
 drop _merge
 

 gen newtemp=IDW_temp+change
 
 
 drop hightemp onedaybefore twodaysbefore heatwave 
 
  sum newtemp,d
  return list
 
*gen hightemp=(newtemp>r(p90))
 
 gen hightemp=(newtemp>27.66)
order hightemp

sort city date 

gen onedaybefore=hightemp[_n-1] if hightemp==1
gen twodaysbefore=onedaybefore[_n-1] if hightemp==1

order onedaybefore hightemp twodaysbefore

gen heatwave=(hightemp==1 & onedaybefore==1 & twodaysbefore==1)
order heatwave
tab heatwave

save ht45_`x'.dta,replace

 sum heatwave  
 
}
 
 
 foreach x of numlist 2030 2050 2090 {
 	use ht_`x',clear
	sum heatwave
	
 }
 
 **** 8.5 
 
 
foreach x of numlist 2030 2050 2090 {

 import delimited "\ts_all_`x'_`x'_rcp85\ts_all.txt", clear 


 sort lat lon
 
 gen id=_n
 
 forvalues i=3/14 {
 	local j=`i'-2
	replace  v`i' = v`i' -273.15
 	rename v`i' month`j'
 }
 
 drop v15
 
 
 reshape long month,i(id) j(j)
 ren month rcp26_`x'
 gen year=`x'
 ren j month
 
 save rcp26_`x'.dta,replace  
 
 
  use rcp26_2020,clear
 
 merge 1:1 lat lon month using rcp26_`x'.dta  
 
  gen change=rcp26_`x'-rcp26_2020
 
 keep id month change lat lon
 save change_`x'.dta,replace
 
 
  use city_latlon_projection.dta
  geonear city latitude longitude using change_2030.dta, ///
   wide neighbors(id lat lon)

     rename nid id
   
   sort id month

   merge m:1 id month using change_`x'.dta
 keep if _merge==3
 drop _merge
 

 gen newtemp=IDW_temp+change
 
 
 drop hightemp onedaybefore twodaysbefore heatwave 
 
  sum newtemp,d
  return list
 
*gen hightemp=(newtemp>r(p90))
 
 gen hightemp=(newtemp>27.66)
order hightemp

sort city date 

gen onedaybefore=hightemp[_n-1] if hightemp==1
gen twodaysbefore=onedaybefore[_n-1] if hightemp==1

order onedaybefore hightemp twodaysbefore

gen heatwave=(hightemp==1 & onedaybefore==1 & twodaysbefore==1)
order heatwave
tab heatwave

save ht85_`x'.dta,replace

 sum heatwave  
 
}
 
 
 foreach x of numlist 2030 2040 2050 {
 	use ht_`x',clear
	sum heatwave
	
 }
 
 
 
 