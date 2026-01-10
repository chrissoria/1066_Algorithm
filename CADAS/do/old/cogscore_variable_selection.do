clear all
set more off
capture log close

*******ADJUST LOCALS HERE**********

***********************************
local user "Chris"  // Change this to "Will" to switch paths

local Chris "/Users/chrissoria/Documents/Research/CADAS_1066/1066"
local Will "PATH"

local path = cond("`user'" == "Chris", "`Chris'", "`Will'")

cd "`path'"

local wave 1

***** SCRIPT STARTS HERE *********

**********************************

log using "CADAS/logs/cogscore_variable_selection.log", text replace

if `wave' == 1 {
    use "`path'/data/1066_Baseline_data.dta"
}

* Standardize variable names to lowercase
foreach var of varlist _all {
    rename `var' `=lower("`var'")'
}
gen pid = (countryid*1000000) + (region*100000) + (houseid*100) + particid

*==============================================================================
* DATA PREPARATION - Same cleaning as in generating_coeffs_from_1066.do
*==============================================================================

* Recode missing/invalid values to 0 for cognitive variables
foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall {
    capture replace `var' = 0 if `var' == .
}

* Replace 99 with 0
foreach var in animals wordimm worddel paper story {
    replace `var' = 0 if `var' == 99
}

* Replace 9 with 0
foreach var in wordimm worddel paper story {
    replace `var' = 0 if `var' == 9
}

* Clean learn variables
foreach var in learn1 learn2 learn3 recall {
    replace `var' = 1 if `var' == 11
    replace `var' = 2 if inlist(`var', 20, 21)
    replace `var' = 3 if inlist(`var', 30, 31)
    replace `var' = 4 if inlist(`var', 40, 41)
    replace `var' = 5 if inlist(`var', 50, 51)
    replace `var' = 6 if inlist(`var', 60, 61)
    replace `var' = 7 if inlist(`var', 70, 71)
    replace `var' = 8 if inlist(`var', 80, 81)
    replace `var' = 9 if inlist(`var', 90, 91)
    replace `var' = . if `var' == 99
}

* Binary variables: recode invalid values
foreach var in name pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag {
    replace `var' = . if `var' >= 2 & `var' <= 9
}

* Create derived variables
gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)

* Cap extreme values
local vars "animals wordimm worddel paper story recall immed nrecall"
local nums "45 3 3 3 6 10 29 1"
local n : word count `vars'
forval i = 1/`n' {
    local var : word `i' of `vars'
    local num : word `i' of `nums'
    replace `var' = . if `var' > `num'
}

* Create proportion scores
gen animtot = animals/23
gen wordtot1 = wordimm/3
gen wordtot2 = worddel/3
gen papertot = paper/3
gen storytot = story/6

* Create nametot
gen nametot_new = 0
replace nametot_new = 1 if name > 0 & !missing(name)
replace nametot_new = 1 if nrecall > 0 & !missing(nrecall)
* Use existing nametot if available, otherwise use our computed version
capture confirm variable nametot
if _rc {
    rename nametot_new nametot
}
else {
    drop nametot_new
}

* Count variable (sum of 24 binary items)
egen count_new = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)

* Replace count if needed
capture confirm variable count
if _rc == 0 {
    drop count
}
rename count_new count

* Calculate cogscore
gen cogscore_calc = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)

*==============================================================================
* STEP 1: CORRELATION MATRIX
*==============================================================================

di _n "=============================================================================="
di "STEP 1: CORRELATION MATRIX - COGSCORE COMPONENTS vs DEMENTIA"
di "=============================================================================="

* List all individual binary items that make up "count"
local binary_items "pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag"

* List the main COGSCORE component scores
local cogscore_components "nametot count animtot wordtot1 wordtot2 papertot storytot"

* Full list of all variables to examine
local all_cog_vars "nametot count animtot wordtot1 wordtot2 papertot storytot `binary_items' animals wordimm worddel paper story"

di _n "--- Correlation of Main COGSCORE Components with Dementia (cdem1066) ---"
pwcorr `cogscore_components' cdem1066, sig star(.05)

di _n "--- Correlation of Individual Binary Items with Dementia ---"
pwcorr `binary_items' cdem1066, sig star(.05)

di _n "--- Correlation Matrix of All COGSCORE Variables ---"
* This creates a large matrix - displaying only correlations with cdem1066
foreach var of local all_cog_vars {
    quietly corr `var' cdem1066
    di "`var'" _col(20) %8.4f r(rho)
}

*==============================================================================
* STEP 2: VARIABLE SELECTION METHODS
*==============================================================================

di _n "=============================================================================="
di "STEP 2: VARIABLE SELECTION - FINDING MOST PREDICTIVE COMBINATIONS"
di "=============================================================================="

* Ensure we have complete cases for the analysis
gen analysis_sample = !missing(cdem1066) & !missing(cogscore_calc)
keep if analysis_sample == 1

*------------------------------------------------------------------------------
* 2A: BASELINE - Full COGSCORE Model
*------------------------------------------------------------------------------
di _n "--- 2A: BASELINE - Logistic Regression with Full COGSCORE ---"
logit cdem1066 cogscore_calc
estat ic
local baseline_aic = r(S)[1,5]
local baseline_bic = r(S)[1,6]
di "Baseline AIC: " `baseline_aic'
di "Baseline BIC: " `baseline_bic'
predict p_baseline, pr
roctab cdem1066 p_baseline
drop p_baseline

*------------------------------------------------------------------------------
* 2B: Component Model - All 7 COGSCORE components separately
*------------------------------------------------------------------------------
di _n "--- 2B: COMPONENT MODEL - 7 COGSCORE Components Separately ---"
logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_components, pr
roctab cdem1066 p_components
drop p_components

*------------------------------------------------------------------------------
* 2C: Forward Stepwise Selection
*------------------------------------------------------------------------------
di _n "--- 2C: FORWARD STEPWISE SELECTION ---"
di "Starting with empty model, adding variables that improve fit"

* Using Stata's built-in stepwise with forward selection
* pe = p-value for entry, pr = p-value for removal
stepwise, pe(.05): logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_forward, pr
roctab cdem1066 p_forward
drop p_forward

*------------------------------------------------------------------------------
* 2D: Backward Stepwise Selection
*------------------------------------------------------------------------------
di _n "--- 2D: BACKWARD STEPWISE SELECTION ---"
di "Starting with full model, removing variables that don't contribute"

stepwise, pr(.10): logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_backward, pr
roctab cdem1066 p_backward
drop p_backward

*------------------------------------------------------------------------------
* 2E: LASSO-type Selection (approximated via penalized likelihood)
*------------------------------------------------------------------------------
di _n "--- 2E: LASSO VARIABLE SELECTION ---"
* Note: Full LASSO requires Stata 16+. Using elastic net if available.
capture {
    lasso logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot, selection(cv)
    lassocoef, display(coef, standardized)
}
if _rc {
    di "LASSO not available in this Stata version. Skipping..."
}

*------------------------------------------------------------------------------
* 2F: Expand to Individual Binary Items
*------------------------------------------------------------------------------
di _n "--- 2F: EXPANDED MODEL - Individual Binary Items ---"
di "Testing if individual items outperform the 'count' aggregate"

* First, full model with all binary items (replacing count)
logit cdem1066 nametot `binary_items' animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_expanded, pr
roctab cdem1066 p_expanded
drop p_expanded

* Stepwise on expanded model
di _n "--- 2F-b: STEPWISE ON EXPANDED MODEL ---"
stepwise, pe(.05): logit cdem1066 nametot `binary_items' animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_expanded_step, pr
roctab cdem1066 p_expanded_step
drop p_expanded_step

*------------------------------------------------------------------------------
* 2G: Compare AIC/BIC Across Key Models
*------------------------------------------------------------------------------
di _n "=============================================================================="
di "SUMMARY: MODEL COMPARISON"
di "=============================================================================="

di _n "Re-running key models to compare AIC/BIC:"

* Model 1: Single cogscore
quietly logit cdem1066 cogscore_calc
estat ic
matrix ic1 = r(S)

* Model 2: 7 components
quietly logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot
estat ic
matrix ic2 = r(S)

* Model 3: Reduced (based on stepwise - rerun to see what was selected)
stepwise, pe(.05) pr(.10): logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot
estat ic
matrix ic3 = r(S)

di _n "Model Comparison Table:"
di "-----------------------------------------------"
di "Model" _col(30) "AIC" _col(45) "BIC"
di "-----------------------------------------------"
di "1. Single COGSCORE" _col(30) %10.2f ic1[1,5] _col(45) %10.2f ic1[1,6]
di "2. 7 Components" _col(30) %10.2f ic2[1,5] _col(45) %10.2f ic2[1,6]
di "3. Stepwise Selected" _col(30) %10.2f ic3[1,5] _col(45) %10.2f ic3[1,6]
di "-----------------------------------------------"

*------------------------------------------------------------------------------
* 2H: Feature Importance via Single-Variable Models
*------------------------------------------------------------------------------
di _n "=============================================================================="
di "FEATURE IMPORTANCE: Individual Variable Predictive Power"
di "=============================================================================="

di "Variable" _col(25) "AUC" _col(35) "Pseudo-R2" _col(50) "Coef" _col(65) "p-value"
di "------------------------------------------------------------------------"

foreach var in nametot count animtot wordtot1 wordtot2 papertot storytot {
    quietly logit cdem1066 `var'
    local pr2 = e(r2_p)
    local coef = _b[`var']
    local pval = 2*normal(-abs(_b[`var']/_se[`var']))
    quietly predict p_temp, pr
    quietly roctab cdem1066 p_temp
    local auc = r(area)
    drop p_temp
    di "`var'" _col(25) %6.4f `auc' _col(35) %8.4f `pr2' _col(50) %8.4f `coef' _col(65) %8.4f `pval'
}

*------------------------------------------------------------------------------
* 2I: Test Alternative Groupings of Binary Items
*------------------------------------------------------------------------------
di _n "=============================================================================="
di "ALTERNATIVE GROUPINGS OF BINARY ITEMS"
di "=============================================================================="

* Create theoretically meaningful sub-scores from the 24 binary items

* Object naming (8 items)
egen object_naming = rowtotal(pencil watch chair shoes knuckle elbow should bridge)

* Language/comprehension (4 items)
egen language = rowtotal(hammer pray chemist repeat)

* Place orientation (4 items)
egen place_orient = rowtotal(town chief street store)

* Memory (2 items)
egen memory_binary = rowtotal(address longmem)

* Time orientation (5 items)
egen time_orient = rowtotal(month day year season)

* Motor/praxis (3 items)
egen motor_praxis = rowtotal(nod point circle pentag)

di _n "--- Model with Theoretically Grouped Sub-scores ---"
logit cdem1066 nametot object_naming language place_orient memory_binary time_orient motor_praxis animtot wordtot1 wordtot2 papertot storytot
estat ic
predict p_grouped, pr
roctab cdem1066 p_grouped
drop p_grouped

di _n "--- Stepwise on Grouped Model ---"
stepwise, pe(.05): logit cdem1066 nametot object_naming language place_orient memory_binary time_orient motor_praxis animtot wordtot1 wordtot2 papertot storytot
estat ic

log close

di _n "=============================================================================="
di "Analysis complete. Log saved to: CADAS/logs/cogscore_variable_selection.log"
di "=============================================================================="
