

log using noplanned_0719.smcl,replace
*** no planned 

use tingdian_all,clear
gen planned=(type=="：计划停电"| type=="：计划检修"| type=="：倒闸操作停电")
drop if planned==1

encode city,gen(cy)
gen n=1
replace city = subinstr(city, "市", "",.) 
replace city = subinstr(city, "停电", "",.)  

gen start_time=substr(startingtime,1,10)
gen end_time=substr(endtime,2,10)  

gen lthendtime=length(endtime)
replace end_time=substr(endtime,1,10) if lthendtime==16
order start_time end_time
gen startdate=date(start_time,"YMD")
order startdate
gen enddate=date(end_time,"YMD")
order startdate enddate

gen startyear=year(startdate)
gen startmonth=month(startdate)
gen endyear=year(enddate)
gen endmonth=month(enddate)
gen ym=ym(startyear,startmonth)

*gen double dt= clock(starttime, "YMD hm") if lth<18 
*replace dt = clock(starttime, "YMD hms") if lth>=18
gen lthend=length(endtime)
gen double dtend = clock(endtime, "YMD hm") if lthend<18 
replace dtend = clock(endtime, "YMD hms") if lthend>=18
gen dif_lth=dtend-dt
gen lth_h=dif_lth/3600000

drop if lth_h<=0
sum lth_h,d
drop if lth_h > r(p99)

rename length LENGTH
rename lth_h length

ren startyear year
ren startmonth month
rename startdate date
replace province=subinstr(province,"停电","",.)

merge m:1 city  using ind_city
drop if _merge==3
drop if _merge==2

gen start_hour=substr(startingtime,12,2)
drop if strpos(start_hour,":")>0
destring start_hour,replace

**** tingdian_district data generation
collapse (sum)length n planned, by(district city province date year month)
save tingdian_district_0407_nop.dta,replace

egen ds=group(city district)
duplicates drop ds year month date, force

xtset ds date
tsfill
sort ds date

bysort ds: replace district=district[_n-1] if district==""
bysort ds: replace year=year[_n-1] if year==.
bysort ds: replace month=month[_n-1] if month==.
bysort ds: replace province=province[_n-1] if province==""
bysort ds: replace city=city[_n-1] if city==""

replace n=0 if n==.
replace length=0 if length==.
sort ds date
replace city = subinstr(city, "市", "",.) 
replace planned=0 if n==0
save tingdian_district_tsfill_0407_nop.dta,replace

***
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

joinby city date using tingdian_district_tsfill_0407_nop.dta /
tab city
duplicates drop ds year month date, force 

sum IDW_temp,d
return list
 
gen hightemp=(IDW_temp>r(p90))
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

egen dsyear=group(ds year)

keep if month>=5 & month<=10


*** RUN REGRESSION
xtset ds date
xtreg lnn heatwave i.year i.month $cov,fe vce(cluster ds)  
estimates store resultsnop1

xtreg lnn heatwave i.year i.month $cov1,fe vce(cluster ds)  
estimates store resultsnop2
esttab resultsnop1 resultsnop2, b(3) se(3) scalars(r2) star( * 0.10 ** 0.05 *** 0.01)

