cd "/hdir/0/chrissoria/ADAMS"
clear all

infile using "adams1asta/ADAMS1TRK_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_tracker.dta, replace

clear

infile using "adams1asta/ADAMS1AB_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionB.dta, replace

clear

infile using "adams1asta/ADAMS1AC_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionC.dta, replace

clear

infile using "adams1asta/ADAMS1AD_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace
tab ADFDX1

save DTA/ADAMS_sectionD.dta, replace

clear

infile using "adams1asta/ADAMS1AE_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionE.dta, replace

clear

infile using "adams1asta/ADAMS1AF_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionF.dta, replace

clear

infile using "adams1asta/ADAMS1AG_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionG.dta, replace

clear

infile using "adams1asta/ADAMS1AH_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionH.dta, replace

clear

infile using "adams1asta/ADAMS1AJ_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionJ.dta, replace

clear

infile using "adams1asta/ADAMS1AM_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionM.dta, replace

clear

infile using "adams1asta/ADAMS1AN_R.dct"

egen hhidpn = concat(HHID PN)
tostring hhidpn, replace

save DTA/ADAMS_sectionN.dta, replace

clear

use "DTA/ADAMS_tracker.dta", clear
sort hhidpn

* merging section B
sort hhidpn
merge 1:1 hhidpn using "DTA/ADAMS_sectionB.dta"
tabulate _merge
*drop if _merge != 3
drop _merge

* Merging section D
sort hhidpn
merge 1:1 hhidpn using "DTA/ADAMS_sectionD.dta"
tabulate _merge
*drop if _merge != 3
drop _merge

* Merging section N
sort hhidpn
merge 1:1 hhidpn using "DTA/ADAMS_sectionN.dta"
tabulate _merge
*drop if _merge != 3
drop _merge

order hhidpn

save DTA/ADAMS_WAVE_A.dta, replace

* Merging section C
merge 1:1 hhidpn using "DTA/ADAMS_sectionC.dta"
tabulate _merge
*drop if _merge != 3
drop _merge

save DTA/ADAMS_WAVE_A_aggressive.dta, replace

use "/hdir/0/chrissoria/hrsdementia_2021_1109.dta", clear

*There's multiple years of data for the same person here, so we'll need to select one.
*ADAMS Wave A data is A group of 1,770 HRS respondent from the HRS 2000 and HRS 2002 waves, so I will keep only those years.

keep if HRS_year == "2002" | HRS_year == "2000"
destring HRS_year, replace

tostring HHID, replace
egen hhidpn = concat(HHID PN)
destring hhidpn, replace force
format hhidpn %12.0f

bysort hhidpn (HRS_year): gen dup_tag = cond(_N==1, 0, _n!=_N)

drop if dup_tag > 0
drop dup_tag

drop hhidpn
egen hhidpn = concat(HHID PN)
tostring hhidpn, replace


save "/hdir/0/chrissoria/ADAMS/DTA/hrsdementia_2021_1109_reproduced.dta", replace

use "/hdir/0/chrissoria/1066/data/LangaWeir2020v2/cogfinalimp_9520wide.dta", clear

drop hhidpn

egen hhidpn = concat(hhid pn)
tostring hhidpn, replace
order hhidpn

save "/hdir/0/chrissoria/ADAMS/DTA/cogfinalimp_9520wide.dta", replace

use "/hdir/0/chrissoria/1066/data/randhrs1992_2016v2_archive_STATA/randhrs1992_2016v2.dta", clear

drop hhidpn

egen hhidpn = concat(hhid pn)
tostring hhidpn, replace
order hhidpn

save "/hdir/0/chrissoria/ADAMS/DTA/randhrs1992_2016v2.dta", replace 


use "/hdir/0/chrissoria/ADAMS/DTA/ADAMS_WAVE_A_aggressive"

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/hrsdementia_2021_1109_reproduced.dta"
drop if _merge == 2 

*292 people of 1770 in the ADAMS wave A data don't have a match from algo data
*after I convert hhid to string there's 40 people that don't match
tab _merge

keep if _merge == 1

drop _merge

save "/hdir/0/chrissoria/hrsdementia_2021_1109_unmatched_2000_2002.dta", replace

use "/hdir/0/chrissoria/hrsdementia_2021_1109.dta", clear

egen hhidpn = concat(HHID PN)

merge m:1 hhidpn using "/hdir/0/chrissoria/hrsdementia_2021_1109_unmatched_2000_2002.dta", force
*when I run it this way I get matches. Why?

tab _merge
*AHA! I think I found the discrepancy! This explains the 8 cases that we had different. 
*there are some people in ADAMS wave A data that have algo data from greater than 2002 years but not 2000-2002 for some reason. 
keep if _merge == 3
