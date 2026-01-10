********************************************************************************
* STEP 3: DETERMINE OPTIMAL STRUCTURE OF PREDICTIVE VARIABLES
********************************************************************************

capture log close step3
log using "$log_path/step3_structure.log", replace name(step3)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 3: DETERMINE OPTIMAL STRUCTURE OF PREDICTIVE VARIABLES"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .
display "Filtered to CDR cases. N = " _N

* 3a. Compare categorical (quintiles) vs continuous

* Original categorical approach (from 10/66)
* Already have: ncogscor, nrelscor, ndelay (quintile categories)
* Already have: bcogscor, brelscor, bdelay (coefficients)

* 3b. Try regular continuous
* Model 1: Continuous variables
* logit cuba_CDR_binary cogscore relscore recall

* Model 2: Categorical (quintiles from 10/66)
* logit cuba_CDR_binary i.ncogscor i.nrelscor i.ndelay

* Model 3: Sample-specific quintiles
* logit cuba_CDR_binary i.ncogscor_quint i.nrelscor_quint i.ndelay_quint

* 3c. Test interaction between cog and relscore
* logit cuba_CDR_binary c.cogscore##c.relscore recall

display _newline(1)
display "STEP 3: TODO - Implement structure comparisons"
display "--------------------------------------------------------------------------------"

log close step3
