********************************************************************************
* STEP 1: JUSTIFY THE INTERACTION BETWEEN COG AND RELSCORE
********************************************************************************

capture log close step1
log using "$log_path/step1_interaction.log", replace name(step1)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 1: JUSTIFY THE INTERACTION BETWEEN COG AND RELSCORE"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .
display "Filtered to CDR cases. N = " _N

* 1a. Simple crosstabs: percent of cases with bad scores in both cog and relscore
* Thresholds: bottom quintile for cog (≤23.699), >5.0 for relscore
gen low_cog = (cogscore <= 23.699) if !missing(cogscore)
gen high_relscore = (relscore > 5.0) if !missing(relscore)

display _newline(1)
display "1a. Cross-tabulation of low cognitive score and high informant score"
display "    low_cog: cogscore <= 23.699 (bottom quintile from 10/66)"
display "    high_relscore: relscore > 5.0 (indicates functional decline)"
display _newline(1)

* Overall distribution
display "Overall distribution:"
tab low_cog high_relscore

* Among dementia cases
display _newline(1)
display "Among dementia cases (cuba_CDR_binary == 1):"
tab low_cog high_relscore if cuba_CDR_binary == 1

* Among non-dementia cases
display _newline(1)
display "Among non-dementia cases (cuba_CDR_binary == 0):"
tab low_cog high_relscore if cuba_CDR_binary == 0

* 1b. Show correlation between cog and relscore
display _newline(2)
display "1b. Correlations between cogscore, relscore, and recall"
correlate cogscore relscore recall

* 1c. Demonstrate that each doesn't always lead to dementia on its own
display _newline(2)
display "1c. Each predictor's relationship with dementia (chi-square tests)"

*-------------------------------------------------------------------------------
* Calculate sensitivity, specificity, PPV, NPV for each predictor
*-------------------------------------------------------------------------------

* Program to calculate and display classification metrics
capture program drop calc_metrics
program define calc_metrics
    args predictor outcome label

    * Get counts from crosstab
    quietly tab `outcome' `predictor', matcell(freq)

    * freq[1,1] = TN (outcome=0, predictor=0)
    * freq[1,2] = FP (outcome=0, predictor=1)
    * freq[2,1] = FN (outcome=1, predictor=0)
    * freq[2,2] = TP (outcome=1, predictor=1)

    local TN = freq[1,1]
    local FP = freq[1,2]
    local FN = freq[2,1]
    local TP = freq[2,2]

    * Calculate metrics
    local sensitivity = `TP' / (`TP' + `FN') * 100
    local specificity = `TN' / (`TN' + `FP') * 100
    local PPV = `TP' / (`TP' + `FP') * 100
    local NPV = `TN' / (`TN' + `FN') * 100

    * Get chi2
    quietly tab `outcome' `predictor', chi2
    local chi2 = r(chi2)

    * Display results
    display _newline(1)
    display "`label' vs dementia:"
    tab `outcome' `predictor', chi2 row col
    display _newline(1)
    display "  Chi2 = " %6.2f `chi2'
    display "  Sensitivity = " %5.1f `sensitivity' "%"
    display "  Specificity = " %5.1f `specificity' "%"
    display "  PPV = " %5.1f `PPV' "%"
    display "  NPV = " %5.1f `NPV' "%"
end

* Calculate metrics for low_cog
calc_metrics low_cog cuba_CDR_binary "low_cog"

* Calculate metrics for high_relscore
calc_metrics high_relscore cuba_CDR_binary "high_relscore"

* Create combined predictor
gen both_bad = (low_cog == 1 & high_relscore == 1) if !missing(low_cog) & !missing(high_relscore)

* Calculate metrics for both_bad
calc_metrics both_bad cuba_CDR_binary "both_bad (low_cog AND high_relscore)"

display _newline(2)
display "--------------------------------------------------------------------------------"
display "STEP 1 COMPLETE"
display "--------------------------------------------------------------------------------"

log close step1
