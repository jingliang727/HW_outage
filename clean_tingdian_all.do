



clear
capture log close
set more off


use tingdian_all,clear

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

capture drop dt
gen double dt= clock(startingtime, "YMD hm") if lth<18 
replace dt = clock(startingtime, "YMD hms") if lth>=18

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

collapse (sum)length n, by(district city province date year month)
save tingdian_district.dta,replace

collapse (sum)length n, by(city province date year month)
save tingdian_city.dta,replace



use tingdian_district.dta,clear 
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

save tingdian_district_tsfill.dta,replace
