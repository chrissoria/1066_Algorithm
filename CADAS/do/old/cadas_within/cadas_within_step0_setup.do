********************************************************************************
* STEP 0: DATA SETUP
* Load raw data files, merge, handle duplicates, append Cuba and DR
********************************************************************************

capture log close step0
log using "$log_path/step0_setup.log", replace name(step0)

display _newline(2)
display "================================================================================"
display "STEP 0: DATA SETUP"
display "================================================================================"
display _newline(1)

local cu_path "/Users/chrissoria/Documents/CADAS/Data/CUBA_out"
local dr_path "/Users/chrissoria/Documents/CADAS/Data/DR_out"

*-------------------------------------------------------------------------------
* LOAD CUBA DATA
*-------------------------------------------------------------------------------
display "Loading Cuba data..."

use "`cu_path'/s_c_i_p_select.dta", clear
gen country = "CU"

tempfile cuba_data
save `cuba_data'

display "Cuba data loaded. N = " _N " observations."

*-------------------------------------------------------------------------------
* LOAD DR DATA
*-------------------------------------------------------------------------------
display "Loading DR data..."

use "`dr_path'/s_c_i_p_select.dta", clear
gen country = "DR"

display "DR data loaded. N = " _N " observations."

*-------------------------------------------------------------------------------
* APPEND CUBA AND DR DATA
*-------------------------------------------------------------------------------
display "Appending Cuba and DR data..."

append using `cuba_data', force

* Handle any cross-country duplicate PIDs
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

display "Data setup complete. Total N = " _N " observations (Cuba + DR)."
tab country
display "--------------------------------------------------------------------------------"

* Save intermediate dataset
save "$within_path/cadas_within_data.dta", replace

log close step0
