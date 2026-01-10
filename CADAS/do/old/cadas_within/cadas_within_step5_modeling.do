********************************************************************************
* STEP 5: CHOOSE MODELING METHOD
********************************************************************************

capture log close step5
log using "$log_path/step5_modeling.log", replace name(step5)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 5: CHOOSE MODELING METHOD"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .
display "Filtered to CDR cases. N = " _N

* OPTION A: Simple logit with train/test split
/*
set seed 12345
gen random = runiform()
gen train = (random < 0.7)

* Train model
logit cuba_CDR_binary cogscore relscore recall if train == 1

* Test model
predict prob if train == 0
gen pred_dem = (prob >= 0.5) if train == 0

* Evaluate
tab cuba_CDR_binary pred_dem if train == 0, chi2
* Calculate sensitivity, specificity, AUC
*/

* OPTION B: K-fold cross-validation (as in ADAMS paper)
/*
* Install crossfold if needed: ssc install crossfold

set seed 12345
* crossfold logit cuba_CDR_binary cogscore relscore recall, k(10)
*/

display _newline(1)
display "STEP 5: TODO - Implement chosen modeling approach"
display "--------------------------------------------------------------------------------"

log close step5
