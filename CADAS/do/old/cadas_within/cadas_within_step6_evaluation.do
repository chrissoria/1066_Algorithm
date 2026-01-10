********************************************************************************
* STEP 6: MODEL COMPARISON AND EVALUATION
********************************************************************************

capture log close step6
log using "$log_path/step6_evaluation.log", replace name(step6)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 6: MODEL COMPARISON AND EVALUATION"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .
display "Filtered to CDR cases. N = " _N

* TODO: Compare models using:
* - AUC (area under ROC curve)
* - Sensitivity and specificity
* - Positive and negative predictive value
* - Calibration plots

********************************************************************************
* FINAL MODEL AND OUTPUT
********************************************************************************

* TODO: Select best model and generate predictions

* Save results
* save "$within_path/cadas_within_predictions.dta", replace

display _newline(1)
display "STEP 6: TODO - Model comparison and final output"
display "--------------------------------------------------------------------------------"

log close step6
