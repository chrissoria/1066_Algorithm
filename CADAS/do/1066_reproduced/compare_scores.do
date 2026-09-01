********************************************************************************
* COMPARE DEMENTIA SCORES ACROSS COUNTRIES
* Summarize means, missings, and cross-tabs for the 3 key binary scores
********************************************************************************

clear all
set more off

capture include "/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_user_define.do"
local path = "/Users/chrissoria/Documents/CADAS/Data"

display _newline(2)
display "================================================================================"
display "COMPARISON OF DEMENTIA SCORES ACROSS COUNTRIES"
display "================================================================================"

*-------------------------------------------------------------------------------
* CUBA
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "CUBA"
display "================================================================================"

use "`path'/CUBA_out/cog_algorithms.dta", clear

display _newline(1)
display "--- Sample size ---"
count

display _newline(1)
display "--- Missing counts ---"
foreach var in cogscore relscore recall dem1066 cdr_binary cadas_dem1066_score cadas_dem1066 cadas_dem1066_ascribed {
    quietly count if missing(`var')
    local n_miss = r(N)
    quietly count
    local n_total = r(N)
    display "  `var': `n_miss' missing out of `n_total'"
}

display _newline(1)
display "--- Continuous score summaries ---"
summarize dem1066_score cadas_dem1066_score cogscore relscore recall

display _newline(1)
display "--- dem1066 (10/66 coefficients, p>=0.5) ---"
tab dem1066, miss

display _newline(1)
display "--- cadas_dem1066 (CADAS logit on CDR, p>=0.5) ---"
tab cadas_dem1066, miss

display _newline(1)
display "--- cadas_dem1066_ascribed (CADAS logit on CDR, p>=0.25) ---"
tab cadas_dem1066_ascribed, miss

display _newline(1)
display "--- Cross-tab: dem1066 vs cadas_dem1066 ---"
tab dem1066 cadas_dem1066, miss

display _newline(1)
display "--- Cross-tab: dem1066 vs cadas_dem1066_ascribed ---"
tab dem1066 cadas_dem1066_ascribed, miss

display _newline(1)
display "--- Cross-tab: cadas_dem1066 vs cadas_dem1066_ascribed ---"
tab cadas_dem1066 cadas_dem1066_ascribed, miss

display _newline(1)
display "--- Means of 3 binary scores (non-missing only) ---"
summarize dem1066 cadas_dem1066 cadas_dem1066_ascribed

* ROC analysis: among cases with CDR data
display _newline(1)
display "--- ROC: dem1066_score predicting cdr_binary ---"
roctab cdr_binary dem1066_score

display _newline(1)
display "--- ROC: cadas_dem1066_score predicting cdr_binary ---"
roctab cdr_binary cadas_dem1066_score

display _newline(1)
display "--- Sensitivity/Specificity: dem1066 vs cdr_binary ---"
tab cdr_binary dem1066, row

display _newline(1)
display "--- Sensitivity/Specificity: cadas_dem1066 vs cdr_binary ---"
tab cdr_binary cadas_dem1066, row

display _newline(1)
display "--- Sensitivity/Specificity: cadas_dem1066_ascribed vs cdr_binary ---"
tab cdr_binary cadas_dem1066_ascribed, row

*-------------------------------------------------------------------------------
* DR
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "DOMINICAN REPUBLIC"
display "================================================================================"

use "`path'/DR_out/cog_algorithms.dta", clear

display _newline(1)
display "--- Sample size ---"
count

display _newline(1)
display "--- Missing counts ---"
foreach var in cogscore relscore recall dem1066 cdr_binary cadas_dem1066_score_DR cadas_dem1066_DR cadas_dem1066_ascribed_DR cadas_dem1066_score cadas_dem1066 cadas_dem1066_ascribed {
    quietly count if missing(`var')
    local n_miss = r(N)
    quietly count
    local n_total = r(N)
    display "  `var': `n_miss' missing out of `n_total'"
}

display _newline(1)
display "--- Continuous score summaries ---"
summarize dem1066_score cadas_dem1066_score_DR cadas_dem1066_score cogscore relscore recall

display _newline(1)
display "--- dem1066 (10/66 coefficients, p>=0.5) ---"
tab dem1066, miss

display _newline(1)
display "--- cadas_dem1066_DR (CADAS logit trained on DR CDR, p>=0.5) ---"
tab cadas_dem1066_DR, miss

display _newline(1)
display "--- cadas_dem1066_ascribed_DR (CADAS logit trained on DR CDR, p>=0.25) ---"
tab cadas_dem1066_ascribed_DR, miss

display _newline(1)
display "--- cadas_dem1066 (Cuba coefficients applied to DR, p>=0.5) ---"
tab cadas_dem1066, miss

display _newline(1)
display "--- cadas_dem1066_ascribed (Cuba coefficients applied to DR, p>=0.25) ---"
tab cadas_dem1066_ascribed, miss

display _newline(1)
display "--- Cross-tab: dem1066 vs cadas_dem1066_DR ---"
tab dem1066 cadas_dem1066_DR, miss

display _newline(1)
display "--- Cross-tab: dem1066 vs cadas_dem1066 (Cuba coefficients) ---"
tab dem1066 cadas_dem1066, miss

display _newline(1)
display "--- Cross-tab: cadas_dem1066_DR vs cadas_dem1066 (Cuba coefficients) ---"
tab cadas_dem1066_DR cadas_dem1066, miss

display _newline(1)
display "--- Means of binary scores (non-missing only) ---"
summarize dem1066 cadas_dem1066_DR cadas_dem1066_ascribed_DR cadas_dem1066 cadas_dem1066_ascribed

* ROC analysis: among cases with CDR data
display _newline(1)
display "--- ROC: dem1066_score predicting cdr_binary ---"
roctab cdr_binary dem1066_score

display _newline(1)
display "--- ROC: cadas_dem1066_score_DR predicting cdr_binary ---"
roctab cdr_binary cadas_dem1066_score_DR

display _newline(1)
display "--- ROC: cadas_dem1066_score (Cuba coefficients) predicting cdr_binary ---"
roctab cdr_binary cadas_dem1066_score

display _newline(1)
display "--- Sensitivity/Specificity: dem1066 vs cdr_binary ---"
tab cdr_binary dem1066, row

display _newline(1)
display "--- Sensitivity/Specificity: cadas_dem1066_DR vs cdr_binary ---"
tab cdr_binary cadas_dem1066_DR, row

display _newline(1)
display "--- Sensitivity/Specificity: cadas_dem1066 (Cuba coefficients) vs cdr_binary ---"
tab cdr_binary cadas_dem1066, row

display _newline(1)
display "--- Sensitivity/Specificity: cadas_dem1066_ascribed_DR vs cdr_binary ---"
tab cdr_binary cadas_dem1066_ascribed_DR, row

*-------------------------------------------------------------------------------
* PR
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "PUERTO RICO"
display "================================================================================"

use "`path'/PR_out/cog_algorithms.dta", clear

display _newline(1)
display "--- Sample size ---"
count

display _newline(1)
display "--- Missing counts ---"
foreach var in cogscore relscore recall dem1066 {
    quietly count if missing(`var')
    local n_miss = r(N)
    quietly count
    local n_total = r(N)
    display "  `var': `n_miss' missing out of `n_total'"
}

display _newline(1)
display "--- Continuous score summaries ---"
summarize dem1066_score cogscore relscore recall

display _newline(1)
display "--- dem1066 (10/66 coefficients, p>=0.5) ---"
tab dem1066, miss

display _newline(1)
display "--- Means of dem1066 (non-missing only) ---"
summarize dem1066

display _newline(1)
display "NOTE: No CDR data for Puerto Rico. CADAS-estimated scores are all missing."

*-------------------------------------------------------------------------------
* SUMMARY TABLE
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "SUMMARY: PREVALENCE RATES (among non-missing)"
display "================================================================================"

display _newline(1)
display "Country       | dem1066    | cadas_dem (p>=0.5) | cadas_ascribed (p>=0.25)"
display "              | (10/66)    | (logit on CDR)     | (logit on CDR)"
display "--------------+------------+--------------------+------------------------"

* Cuba
use "`path'/CUBA_out/cog_algorithms.dta", clear
quietly summarize dem1066
local cu_1066 : display %5.3f r(mean)
quietly summarize cadas_dem1066
local cu_cadas : display %5.3f r(mean)
quietly summarize cadas_dem1066_ascribed
local cu_ascr : display %5.3f r(mean)
display "Cuba          | `cu_1066'      | `cu_cadas'              | `cu_ascr'"

* DR
use "`path'/DR_out/cog_algorithms.dta", clear
quietly summarize dem1066
local dr_1066 : display %5.3f r(mean)
quietly summarize cadas_dem1066_DR
local dr_cadas : display %5.3f r(mean)
quietly summarize cadas_dem1066_ascribed_DR
local dr_ascr : display %5.3f r(mean)
display "DR            | `dr_1066'      | `dr_cadas'              | `dr_ascr'"

* PR
use "`path'/PR_out/cog_algorithms.dta", clear
quietly summarize dem1066
local pr_1066 : display %5.3f r(mean)
display "PR            | `pr_1066'      | N/A                | N/A"

display "--------------+------------+--------------------+------------------------"
