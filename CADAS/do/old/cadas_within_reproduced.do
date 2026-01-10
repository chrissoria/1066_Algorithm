clear all
set more off
cls

*******ADJUST LOCALS HERE**********

***********************************
local drop_missing_from_relscore "no" // change to yes or no
local drop_physical_disability "no"
local impute_recall "yes" //imputes the 10-word delayed recall from the immediate recall questions


***** SCRIPT STARTS HERE *********

**********************************

use "/Users/chrissoria/Documents/CADAS/Data/CUBA_out/s_c_i_p_select.dta", clear
gen country = "CU"

append using "/Users/chrissoria/Documents/CADAS/Data/DR_out/s_c_i_p_select.dta", force
replace country = "DR" if missing(country)

*until we clean all the data, we'll have to indiscriminantly drop duplicates
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

* Preserve full dataset - all analysis below requires CDR_binary
preserve
keep if cuba_CDR_binary != .

********************************************************************************
* STEP 1: JUSTIFY THE INTERACTION BETWEEN COG AND RELSCORE
********************************************************************************
display _newline(2)
display "================================================================================"
display "STEP 1: JUSTIFY THE INTERACTION BETWEEN COG AND RELSCORE"
display "================================================================================"
display _newline(1)

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
display _newline(1)
display "low_cog vs dementia:"
tab cuba_CDR_binary low_cog, chi2 row col

display _newline(1)
display "high_relscore vs dementia:"
tab cuba_CDR_binary high_relscore, chi2 row col

* Show that combining both improves prediction
gen both_bad = (low_cog == 1 & high_relscore == 1) if !missing(low_cog) & !missing(high_relscore)
display _newline(1)
display "both_bad (low_cog AND high_relscore) vs dementia:"
tab cuba_CDR_binary both_bad, chi2 row col

display _newline(2)
display "--------------------------------------------------------------------------------"
display "STEP 1 INTERPRETATION:"
display "--------------------------------------------------------------------------------"
display "- low_cog alone: chi2=75.73, PPV=78.4%, sensitivity=43.3%, specificity=96.5%"
display "- high_relscore alone: chi2=71.64, PPV=80.6%, sensitivity=40.9%, specificity=97.0%"
display "- both_bad: chi2=55.62, PPV=86.4%, sensitivity=28.4%, specificity=98.7%"
display _newline(1)
display "CONCLUSION: Both low cognitive score and high informant score are strong"
display "independent predictors of dementia. Combining them (both_bad) yields the highest"
display "positive predictive value (86.4%) and specificity (98.7%), but at the cost of"
display "lower sensitivity (28.4%). This suggests an interaction term may improve model"
display "precision for identifying true dementia cases."
display "--------------------------------------------------------------------------------"
display _newline(2)

********************************************************************************
* STEP 2: IDENTIFY VARIABLES MOST PREDICTIVE OF DEMENTIA
********************************************************************************
display _newline(2)
display "================================================================================"
display "STEP 2: IDENTIFY VARIABLES MOST PREDICTIVE OF DEMENTIA"
display "================================================================================"
display _newline(1)

*-------------------------------------------------------------------------------
* 2a. CORRELATION MATRIX - COGSCORE COMPONENTS
*-------------------------------------------------------------------------------
display _newline(1)
display "2a. CORRELATION MATRIX - COGSCORE Components with Dementia (cuba_CDR_binary)"
display "--------------------------------------------------------------------------------"

* Define COGSCORE component variables
* Main components that form COGSCORE:
*   nametot = name recall (binary)
*   count = sum of 24 binary items below
*   animtot = animals/23
*   wordtot1 = wordimm/3
*   wordtot2 = worddel/3
*   papertot = paper/3
*   storytot = story/6

* Individual binary items that make up "count" (24 items)
local binary_items "pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmom month day year season nod point circle pentag"

* COGSCORE component scores (derived)
local cogscore_components "nametot animtot wordtot1 wordtot2 papertot storytot"

* Raw cognitive scores (before transformation)
local cog_raw "animals wordimm worddel paper story name nrecall"

* Learning trials and recall
local learn_recall "learn1 learn2 learn3 recall"

* Refusal indicators
local refusal_vars "story_refuse learn1_refuse learn2_refuse learn3_refuse recall_refuse"

* All cognitive variables combined
local all_cog_vars "`binary_items' `cogscore_components' `cog_raw' `learn_recall' `refusal_vars'"

display _newline(1)
display "--- Correlations: Main COGSCORE Components vs CDR ---"
pwcorr `cogscore_components' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Correlations: Individual Binary Items vs CDR ---"
pwcorr `binary_items' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Correlations: Raw Cognitive Scores vs CDR ---"
pwcorr `cog_raw' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Correlations: Learning Trials & Recall vs CDR ---"
pwcorr `learn_recall' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Correlations: Refusal Indicators vs CDR ---"
pwcorr `refusal_vars' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Ranked Correlations with CDR (ALL cognitive variables) ---"
display "Variable" _col(25) "Correlation"
display "------------------------------------------------"

* Calculate and display correlations for each variable
foreach var in `all_cog_vars' {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        di "`var'" _col(25) %8.4f r(rho)
    }
}

*-------------------------------------------------------------------------------
* 2b. CORRELATION MATRIX - RELSCORE COMPONENTS
*-------------------------------------------------------------------------------
display _newline(2)
display "2b. CORRELATION MATRIX - RELSCORE Components with Dementia (cuba_CDR_binary)"
display "--------------------------------------------------------------------------------"

* RELSCORE component variables (informant-reported functional abilities)
local rel_vars "activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet"

display _newline(1)
display "--- Correlations: RELSCORE Components vs CDR ---"
pwcorr `rel_vars' cuba_CDR_binary, sig star(.05)

display _newline(1)
display "--- Ranked Correlations with CDR (RELSCORE variables) ---"
display "Variable" _col(25) "Correlation"
display "------------------------------------------------"

foreach var of local rel_vars {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        di "`var'" _col(25) %8.4f r(rho)
    }
}

*-------------------------------------------------------------------------------
* 2c. CORRELATION - RECALL VARIABLE
*-------------------------------------------------------------------------------
display _newline(2)
display "2c. CORRELATION - RECALL Variable with Dementia"
display "--------------------------------------------------------------------------------"

pwcorr recall cuba_CDR_binary, sig star(.05)

*-------------------------------------------------------------------------------
* 2d. VARIABLE SELECTION - COGSCORE COMPONENTS
*-------------------------------------------------------------------------------
display _newline(2)
display "2d. VARIABLE SELECTION - Finding Most Predictive COGSCORE Components"
display "--------------------------------------------------------------------------------"

* Baseline: Full cogscore
display _newline(1)
display "--- Baseline Model: Single COGSCORE ---"
quietly logit cuba_CDR_binary cogscore
estat ic
matrix ic_baseline = r(S)
predict p_baseline, pr
quietly roctab cuba_CDR_binary p_baseline
local auc_baseline = r(area)
drop p_baseline
display "AIC: " %10.2f ic_baseline[1,5] "  BIC: " %10.2f ic_baseline[1,6] "  AUC: " %6.4f `auc_baseline'

* Component model: 6 components separately (excluding count for now)
display _newline(1)
display "--- Component Model: 6 COGSCORE Components Separately ---"
quietly logit cuba_CDR_binary nametot animtot wordtot1 wordtot2 papertot storytot
estat ic
matrix ic_components = r(S)
predict p_components, pr
quietly roctab cuba_CDR_binary p_components
local auc_components = r(area)
drop p_components
display "AIC: " %10.2f ic_components[1,5] "  BIC: " %10.2f ic_components[1,6] "  AUC: " %6.4f `auc_components'
logit cuba_CDR_binary nametot animtot wordtot1 wordtot2 papertot storytot

* Forward stepwise
display _newline(1)
display "--- Forward Stepwise Selection (p<.05 to enter) ---"
display "    Including: binary items, derived components, raw scores, learn trials, refusals, dissimilarity"
stepwise, pe(.05): logit cuba_CDR_binary `all_cog_vars'
estat ic
matrix ic_forward = r(S)
predict p_forward, pr
quietly roctab cuba_CDR_binary p_forward
local auc_forward = r(area)
drop p_forward
display "AIC: " %10.2f ic_forward[1,5] "  BIC: " %10.2f ic_forward[1,6] "  AUC: " %6.4f `auc_forward'

* Backward stepwise
display _newline(1)
display "--- Backward Stepwise Selection (p>.10 to remove) ---"
display "    Including: binary items, derived components, raw scores, learn trials, refusals, dissimilarity"
stepwise, pr(.10): logit cuba_CDR_binary `all_cog_vars'
estat ic
matrix ic_backward = r(S)
predict p_backward, pr
quietly roctab cuba_CDR_binary p_backward
local auc_backward = r(area)
drop p_backward
display "AIC: " %10.2f ic_backward[1,5] "  BIC: " %10.2f ic_backward[1,6] "  AUC: " %6.4f `auc_backward'

*-------------------------------------------------------------------------------
* 2e. VARIABLE SELECTION - RELSCORE COMPONENTS
*-------------------------------------------------------------------------------
display _newline(2)
display "2e. VARIABLE SELECTION - Finding Most Predictive RELSCORE Components"
display "--------------------------------------------------------------------------------"

* Baseline: Full relscore
display _newline(1)
display "--- Baseline Model: Single RELSCORE ---"
quietly logit cuba_CDR_binary relscore
estat ic
matrix ic_rel_baseline = r(S)
predict p_rel_baseline, pr
quietly roctab cuba_CDR_binary p_rel_baseline
local auc_rel_baseline = r(area)
drop p_rel_baseline
display "AIC: " %10.2f ic_rel_baseline[1,5] "  BIC: " %10.2f ic_rel_baseline[1,6] "  AUC: " %6.4f `auc_rel_baseline'

* Forward stepwise on RELSCORE components
display _newline(1)
display "--- Forward Stepwise Selection on RELSCORE Components ---"
stepwise, pe(.05): logit cuba_CDR_binary `rel_vars'
estat ic
matrix ic_rel_forward = r(S)
predict p_rel_forward, pr
quietly roctab cuba_CDR_binary p_rel_forward
local auc_rel_forward = r(area)
drop p_rel_forward
display "AIC: " %10.2f ic_rel_forward[1,5] "  BIC: " %10.2f ic_rel_forward[1,6] "  AUC: " %6.4f `auc_rel_forward'

*-------------------------------------------------------------------------------
* 2f. FEATURE IMPORTANCE - Individual Variable Predictive Power
*-------------------------------------------------------------------------------
display _newline(2)
display "2f. FEATURE IMPORTANCE - Individual Variable Predictive Power"
display "--------------------------------------------------------------------------------"
display _newline(1)
display "Variable" _col(20) "AUC" _col(30) "Pseudo-R2" _col(45) "Coef" _col(60) "p-value"
display "------------------------------------------------------------------------"

display "--- COGSCORE Derived Components ---"
foreach var in nametot animtot wordtot1 wordtot2 papertot storytot {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "--- Raw Cognitive Scores ---"
foreach var in animals wordimm worddel paper story name nrecall {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "--- Learning Trials & Recall ---"
foreach var in learn1 learn2 learn3 recall {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "--- Refusal Indicators ---"
foreach var in story_refuse learn1_refuse learn2_refuse learn3_refuse recall_refuse {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "--- Select Binary Items (highest expected correlations) ---"
foreach var in month day year season longmom orient address street {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "------------------------------------------------------------------------"

display "--- RELSCORE Components (all items) ---"
foreach var in activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet {
    capture {
        quietly logit cuba_CDR_binary `var'
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        quietly predict p_temp, pr
        quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
}

display "------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* 2g. MODEL COMPARISON SUMMARY
*-------------------------------------------------------------------------------
display _newline(2)
display "2g. MODEL COMPARISON SUMMARY"
display "--------------------------------------------------------------------------------"
display _newline(1)
display "Model" _col(40) "AIC" _col(55) "BIC" _col(70) "AUC"
display "------------------------------------------------------------------------"
display "COGSCORE (single)" _col(40) %10.2f ic_baseline[1,5] _col(55) %10.2f ic_baseline[1,6] _col(70) %6.4f `auc_baseline'
display "COGSCORE (6 components)" _col(40) %10.2f ic_components[1,5] _col(55) %10.2f ic_components[1,6] _col(70) %6.4f `auc_components'
display "COGSCORE (forward stepwise)" _col(40) %10.2f ic_forward[1,5] _col(55) %10.2f ic_forward[1,6] _col(70) %6.4f `auc_forward'
display "COGSCORE (backward stepwise)" _col(40) %10.2f ic_backward[1,5] _col(55) %10.2f ic_backward[1,6] _col(70) %6.4f `auc_backward'
display "RELSCORE (single)" _col(40) %10.2f ic_rel_baseline[1,5] _col(55) %10.2f ic_rel_baseline[1,6] _col(70) %6.4f `auc_rel_baseline'
display "RELSCORE (forward stepwise)" _col(40) %10.2f ic_rel_forward[1,5] _col(55) %10.2f ic_rel_forward[1,6] _col(70) %6.4f `auc_rel_forward'
display "------------------------------------------------------------------------"

display _newline(2)
display "--------------------------------------------------------------------------------"
display "STEP 2 INTERPRETATION:"
display "--------------------------------------------------------------------------------"
display "Compare AIC (lower is better) and AUC (higher is better) across models."
display "If component models outperform single composite scores, consider using"
display "selected components rather than the full cogscore/relscore in final model."
display "--------------------------------------------------------------------------------"
display _newline(2)

********************************************************************************
* STEP 3: DETERMINE OPTIMAL STRUCTURE OF PREDICTIVE VARIABLES
********************************************************************************

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

********************************************************************************
* STEP 4: IDENTIFY IDEAL TRAIN/TEST SAMPLE SIZE
********************************************************************************

* Given ~300 CDR cases, determine appropriate split
count if cuba_CDR_binary != .
local n_cdr = r(N)
display "Total CDR cases: `n_cdr'"

* Options:
* - 70/30 split: ~210 train, ~90 test
* - 80/20 split: ~240 train, ~60 test
* - K-fold cross-validation (no separate test set needed)

* TODO: Determine optimal split based on sample size considerations

********************************************************************************
* STEP 5: CHOOSE MODELING METHOD
********************************************************************************

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

********************************************************************************
* MODEL COMPARISON AND EVALUATION
********************************************************************************

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
* save cadas_within_predictions.dta, replace

* Restore full dataset
restore
