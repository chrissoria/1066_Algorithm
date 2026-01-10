********************************************************************************
* CHECK VARIABLE CONTRIBUTIONS TO DEMENTIA PREDICTION
* How much does each variable (cogscore, relscore, recall) contribute?
********************************************************************************

clear all
set more off

* Load 1066 baseline data (Cuba only)
use "/Users/chrissoria/Documents/Research/CADAS_1066/1066/data/1066_Baseline_data.dta", clear
keep if countryid == 1

display "N = " _N

*-------------------------------------------------------------------------------
* STANDARDIZE VARIABLES (to compare coefficients on same scale)
*-------------------------------------------------------------------------------

foreach var in cogscore relscore recall {
    quietly sum `var'
    gen `var'_z = (`var' - r(mean)) / r(sd)
}

display _newline(1)
display "================================================================================"
display "1. STANDARDIZED COEFFICIENTS (same scale comparison)"
display "================================================================================"

logit cdem1066 cogscore_z relscore_z recall_z
display ""
display "Interpretation: Larger absolute coefficient = larger contribution"
display "  cogscore_z: " %6.3f _b[cogscore_z]
display "  relscore_z: " %6.3f _b[relscore_z]
display "  recall_z:   " %6.3f _b[recall_z]

*-------------------------------------------------------------------------------
* MODEL COMPARISON: DROP EACH VARIABLE
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "2. AUC WHEN DROPPING EACH VARIABLE"
display "================================================================================"

* Full model
quietly logit cdem1066 cogscore relscore recall
quietly predict p_full, pr
quietly roctab cdem1066 p_full
local auc_full = r(area)
display "Full model (all 3 vars):     AUC = " %5.3f `auc_full'

* Drop cogscore
quietly logit cdem1066 relscore recall
quietly predict p_no_cog, pr
quietly roctab cdem1066 p_no_cog
local auc_no_cog = r(area)
display "Without cogscore:            AUC = " %5.3f `auc_no_cog' "  (drop of " %5.3f `auc_full' - `auc_no_cog' ")"

* Drop relscore
quietly logit cdem1066 cogscore recall
quietly predict p_no_rel, pr
quietly roctab cdem1066 p_no_rel
local auc_no_rel = r(area)
display "Without relscore:            AUC = " %5.3f `auc_no_rel' "  (drop of " %5.3f `auc_full' - `auc_no_rel' ")"

* Drop recall
quietly logit cdem1066 cogscore relscore
quietly predict p_no_rec, pr
quietly roctab cdem1066 p_no_rec
local auc_no_rec = r(area)
display "Without recall:              AUC = " %5.3f `auc_no_rec' "  (drop of " %5.3f `auc_full' - `auc_no_rec' ")"

*-------------------------------------------------------------------------------
* SINGLE VARIABLE MODELS
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "3. AUC WITH EACH VARIABLE ALONE"
display "================================================================================"

* Cogscore only
quietly logit cdem1066 cogscore
quietly predict p_cog_only, pr
quietly roctab cdem1066 p_cog_only
local auc_cog = r(area)
display "Cogscore alone:              AUC = " %5.3f `auc_cog'

* Relscore only
quietly logit cdem1066 relscore
quietly predict p_rel_only, pr
quietly roctab cdem1066 p_rel_only
local auc_rel = r(area)
display "Relscore alone:              AUC = " %5.3f `auc_rel'

* Recall only
quietly logit cdem1066 recall
quietly predict p_rec_only, pr
quietly roctab cdem1066 p_rec_only
local auc_rec = r(area)
display "Recall alone:                AUC = " %5.3f `auc_rec'

*-------------------------------------------------------------------------------
* CORRELATION BETWEEN PREDICTORS
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "4. CORRELATIONS BETWEEN PREDICTORS"
display "================================================================================"

correlate cogscore relscore recall

*-------------------------------------------------------------------------------
* SUMMARY
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "SUMMARY"
display "================================================================================"
display ""
display "Variable importance (by AUC drop when removed):"
display "  1. Relscore:  " %5.3f `auc_full' - `auc_no_rel' " AUC drop"
display "  2. Cogscore:  " %5.3f `auc_full' - `auc_no_cog' " AUC drop"
display "  3. Recall:    " %5.3f `auc_full' - `auc_no_rec' " AUC drop"
display ""
display "Variable importance (by AUC alone):"
display "  1. Relscore:  " %5.3f `auc_rel'
display "  2. Cogscore:  " %5.3f `auc_cog'
display "  3. Recall:    " %5.3f `auc_rec'
