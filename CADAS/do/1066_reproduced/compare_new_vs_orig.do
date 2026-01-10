********************************************************************************
* COMPARE: New refactored 1066 vs Original 1066
********************************************************************************

clear all
set more off

display _newline(2)
display "================================================================================"
display "COMPARING NEW vs ORIGINAL 1066 OUTPUT"
display "================================================================================"

*-------------------------------------------------------------------------------
* LOAD NEW VERSION
*-------------------------------------------------------------------------------

use "/Users/chrissoria/Documents/CADAS/Data/CUBA_out/1066.dta", clear

* Rename to avoid conflicts
rename cogscore new_cogscore
rename relscore new_relscore
rename recall new_recall
rename dem1066_score new_dem1066_score
rename dem1066 new_dem1066
rename dem1066_quint new_dem1066_quint

keep pid new_*
tempfile new_data
save `new_data'

display "New data loaded: " _N " observations"

*-------------------------------------------------------------------------------
* LOAD ORIGINAL VERSION
*-------------------------------------------------------------------------------

use "/Users/chrissoria/Documents/CADAS/Data/CUBA_out/1066_orig.dta", clear

* Rename to avoid conflicts
rename cogscore orig_cogscore
rename relscore orig_relscore
rename recall orig_recall
rename dem1066_score orig_dem1066_score
rename dem1066 orig_dem1066
capture rename dem1066_quint orig_dem1066_quint

keep pid orig_*
display "Original data loaded: " _N " observations"

*-------------------------------------------------------------------------------
* MERGE AND COMPARE
*-------------------------------------------------------------------------------

merge 1:1 pid using `new_data', nogen

display _newline(2)
display "================================================================================"
display "COMPARISON RESULTS"
display "================================================================================"

* Calculate differences
gen diff_cogscore = new_cogscore - orig_cogscore
gen diff_relscore = new_relscore - orig_relscore
gen diff_recall = new_recall - orig_recall
gen diff_dem1066_score = new_dem1066_score - orig_dem1066_score
gen diff_dem1066 = new_dem1066 - orig_dem1066

display _newline(1)
display "1. COGSCORE COMPARISON:"
summarize orig_cogscore new_cogscore diff_cogscore
count if abs(diff_cogscore) > 0.0001 & !missing(diff_cogscore)
display "   Cases with difference: " r(N)

display _newline(1)
display "2. RELSCORE COMPARISON:"
summarize orig_relscore new_relscore diff_relscore
count if abs(diff_relscore) > 0.0001 & !missing(diff_relscore)
display "   Cases with difference: " r(N)

display _newline(1)
display "3. RECALL COMPARISON:"
summarize orig_recall new_recall diff_recall
count if abs(diff_recall) > 0.0001 & !missing(diff_recall)
display "   Cases with difference: " r(N)

display _newline(1)
display "4. DEM1066_SCORE COMPARISON:"
summarize orig_dem1066_score new_dem1066_score diff_dem1066_score
count if abs(diff_dem1066_score) > 0.0001 & !missing(diff_dem1066_score)
display "   Cases with difference: " r(N)

display _newline(1)
display "5. DEM1066 CLASSIFICATION CROSSTAB:"
tab orig_dem1066 new_dem1066, miss

count if diff_dem1066 != 0 & !missing(orig_dem1066) & !missing(new_dem1066)
display "   Cases with different classification: " r(N)

display _newline(2)
display "================================================================================"
display "SUMMARY"
display "================================================================================"
display "If relscore differs, it's because the new version uses freshly computed"
display "relscore while the original may have used a pre-existing variable."
display "================================================================================"
