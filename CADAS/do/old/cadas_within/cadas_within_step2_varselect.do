********************************************************************************
* STEP 2: IDENTIFY VARIABLES MOST PREDICTIVE OF DEMENTIA
********************************************************************************

capture log close step2
log using "$log_path/step2_varselect.log", replace name(step2)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 2: IDENTIFY VARIABLES MOST PREDICTIVE OF DEMENTIA"
display "================================================================================"
display _newline(1)

* Filter to CDR cases for analysis
keep if cuba_CDR_binary != .
display "Filtered to CDR cases. N = " _N

*-------------------------------------------------------------------------------
* Define all variable lists (self-contained)
*-------------------------------------------------------------------------------

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

* RELSCORE component variables (informant-reported functional abilities)
local rel_vars "activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet"

*-------------------------------------------------------------------------------
* 2a. CORRELATION MATRIX - COGSCORE COMPONENTS
*-------------------------------------------------------------------------------
display _newline(1)
display "2a. CORRELATION MATRIX - COGSCORE Components with Dementia (cuba_CDR_binary)"
display "--------------------------------------------------------------------------------"

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
* 2c2. CORRELATION PLOTS - Visual Display of Correlations with CDR
*-------------------------------------------------------------------------------
display _newline(2)
display "2c2. GENERATING CORRELATION PLOTS"
display "--------------------------------------------------------------------------------"

* Create a temporary dataset for COGSCORE component correlations
preserve
clear
input str15 variable corr
end

* COGSCORE components
local cogscore_plot "nametot animtot wordtot1 wordtot2 papertot storytot"
local n_cog : word count `cogscore_plot'

* Restore to get correlations, then build plot data
restore
preserve

* Generate correlation values for COGSCORE derived components (6 components)
tempfile corr_cog
postfile cog_corr str20 variable double corr using `corr_cog', replace
foreach var in nametot animtot wordtot1 wordtot2 papertot storytot {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post cog_corr ("`var'") (r(rho))
    }
}
postclose cog_corr

* Create COGSCORE components correlation bar chart
use `corr_cog', clear
gen order = _n
gen abs_corr = abs(corr)

graph hbar corr, over(variable, sort(abs_corr) descending label(labsize(small))) ///
    title("COGSCORE Components: Correlation with CDR", size(medium)) ///
    ytitle("Correlation Coefficient") ///
    ylabel(-0.5(0.1)0.1, angle(horizontal)) ///
    bar(1, color(navy)) ///
    yline(0, lcolor(black) lwidth(thin)) ///
    note("Negative correlations = better cognitive score associated with lower dementia probability")

graph export "$plot_path/cogscore_components_corr_cdr.png", replace width(1200)
display "Saved: cogscore_components_corr_cdr.png"

restore
preserve

* Generate correlation values for ALL COGSCORE variables
* Includes: binary items, derived components, raw scores, learning trials
tempfile corr_cog_all
postfile cog_corr_all str20 variable double corr using `corr_cog_all', replace

* Binary items (26 items)
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmom month day year season nod point circle pentag {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post cog_corr_all ("`var'") (r(rho))
    }
}

* Derived components
foreach var in nametot animtot wordtot1 wordtot2 papertot storytot {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post cog_corr_all ("`var'") (r(rho))
    }
}

* Raw cognitive scores
foreach var in animals wordimm worddel paper story name nrecall {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post cog_corr_all ("`var'") (r(rho))
    }
}

* Learning trials and recall
foreach var in learn1 learn2 learn3 recall {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post cog_corr_all ("`var'") (r(rho))
    }
}

postclose cog_corr_all

* Create ALL cognitive variables correlation bar chart
use `corr_cog_all', clear
gen order = _n
gen abs_corr = abs(corr)

graph hbar corr, over(variable, sort(abs_corr) descending label(labsize(vsmall))) ///
    title("All Cognitive Variables: Correlation with CDR", size(medium)) ///
    ytitle("Correlation Coefficient") ///
    ylabel(-0.5(0.1)0.1, angle(horizontal)) ///
    bar(1, color(navy)) ///
    yline(0, lcolor(black) lwidth(thin)) ///
    note("Negative correlations = better cognitive performance associated with lower dementia probability", size(vsmall))

graph export "$plot_path/cogscore_all_vars_corr_cdr.png", replace width(1200) height(1000)
display "Saved: cogscore_all_vars_corr_cdr.png"

restore
preserve

* Generate correlation values for RELSCORE components
tempfile corr_rel
postfile rel_corr str20 variable double corr using `corr_rel', replace
foreach var in activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed toilet {
    capture quietly corr `var' cuba_CDR_binary
    if _rc == 0 {
        post rel_corr ("`var'") (r(rho))
    }
}
postclose rel_corr

* Create RELSCORE correlation bar chart
use `corr_rel', clear
gen order = _n
gen abs_corr = abs(corr)

graph hbar corr, over(variable, sort(abs_corr) descending label(labsize(vsmall))) ///
    title("RELSCORE Components: Correlation with CDR", size(medium)) ///
    ytitle("Correlation Coefficient") ///
    ylabel(-0.1(0.1)0.6, angle(horizontal)) ///
    bar(1, color(maroon)) ///
    yline(0, lcolor(black) lwidth(thin)) ///
    note("Positive correlations = higher informant concern associated with higher dementia probability")

graph export "$plot_path/relscore_corr_cdr.png", replace width(1200)
display "Saved: relscore_corr_cdr.png"

restore

display "Correlation plots saved to: $plot_path/"

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
display "    Including: binary items, derived components, raw scores, learn trials, refusals"
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
display "    Including: binary items, derived components, raw scores, learn trials, refusals"
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
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
    }
}

display "--- Raw Cognitive Scores ---"
foreach var in animals wordimm worddel paper story name nrecall {
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
    }
}

display "--- Learning Trials & Recall ---"
foreach var in learn1 learn2 learn3 recall {
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
    }
}

display "--- Refusal Indicators ---"
foreach var in story_refuse learn1_refuse learn2_refuse learn3_refuse recall_refuse {
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
    }
}

display "--- Select Binary Items (highest expected correlations) ---"
foreach var in month day year season longmom orient address street {
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
    }
}

display "------------------------------------------------------------------------"

display "--- RELSCORE Components (all items) ---"
foreach var in activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet {
    capture quietly logit cuba_CDR_binary `var'
    if _rc == 0 {
        local pr2 = e(r2_p)
        local coef = _b[`var']
        local pval = 2*normal(-abs(_b[`var']/_se[`var']))
        capture quietly predict p_temp, pr
        capture quietly roctab cuba_CDR_binary p_temp
        local auc = r(area)
        capture drop p_temp
        di "`var'" _col(20) %6.4f `auc' _col(30) %8.4f `pr2' _col(45) %8.4f `coef' _col(60) %8.4f `pval'
    }
    else {
        di "`var'" _col(20) "  --  " _col(30) "   --   " _col(45) "   --   " _col(60) "(model failed)"
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

log close step2
