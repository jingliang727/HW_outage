


***rcp2.6
clear
use ht_2030,clear

gen no=1

collapse (sum)heatwave no ,by(district provincename)

gen pro=heatwave/no

drop if pro==1
keep district pro provincename
export delimited using "temp_pro_2030",replace


foreach x of numlist 2030 2050 2090 {

use ht_`x',clear

gen no=1

collapse (sum)heatwave no ,by(district provincename)

gen pro_`x'=heatwave/no
rename provincename name

drop if pro_`x'==1
keep district pro_`x' name
export delimited using "temp_pro_`x'",replace


}

** rcp4.5


clear


foreach x of numlist 2030 2050 2090 {

use ht45_`x',clear

gen no=1

collapse (sum)heatwave no ,by(district provincename)

gen pro_`x'=heatwave/no
rename provincename name

drop if pro_`x'==1
keep district pro_`x' name
export delimited using "temp_pro45_`x'",replace


}


** 8.5


clear


foreach x of numlist 2030 2050 2090 {

use ht85_`x',clear

gen no=1

collapse (sum)heatwave no ,by(district provincename)

gen pro_`x'=heatwave/no
rename provincename name

drop if pro_`x'==1
keep district pro_`x' name
export delimited using "temp_pro85_`x'",replace


}