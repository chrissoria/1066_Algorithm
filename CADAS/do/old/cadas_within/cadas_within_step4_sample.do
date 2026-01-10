********************************************************************************
* STEP 4: IDENTIFY IDEAL TRAIN/TEST SAMPLE SIZE
********************************************************************************

capture log close step4
log using "$log_path/step4_sample.log", replace name(step4)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 4: IDENTIFY IDEAL TRAIN/TEST SAMPLE SIZE"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .

* Given ~300 CDR cases, determine appropriate split
count
local n_cdr = r(N)
display "Total CDR cases: `n_cdr'"

* Options:
* - 70/30 split: ~210 train, ~90 test
* - 80/20 split: ~240 train, ~60 test
* - K-fold cross-validation (no separate test set needed)

display _newline(1)
display "STEP 4: TODO - Determine optimal split based on sample size considerations"
display "--------------------------------------------------------------------------------"

log close step4
