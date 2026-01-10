********************************************************************************
* COMPARISON SCRIPT: Original vs Refactored 10/66 Algorithm
* Run this to verify the refactored version produces equivalent results
********************************************************************************

clear all
set more off
capture log close

log using "/Users/chrissoria/Documents/Research/1066/CADAS/logs/compare_versions.log", replace

display _newline(2)
display "================================================================================"
display "COMPARISON: Original vs Refactored 10/66 Algorithm"
display "================================================================================"
display _newline(1)

*-------------------------------------------------------------------------------
* PART 1: Run the ORIGINAL script and save results
*-------------------------------------------------------------------------------

display "RUNNING ORIGINAL SCRIPT..."
display "--------------------------------------------------------------------------------"

capture noisily do "/Users/chrissoria/Documents/CADAS/do/cadas_1066_reproduced.do"
if _rc {
    display "ERROR: Original script failed with error code " _rc
    exit _rc
}

* Save key variables from original
gen version = "original"

* Rename to avoid conflicts (use capture in case variable doesn't exist)
capture rename cogscore orig_cogscore
if _rc gen orig_cogscore = .

capture rename relscore orig_relscore
if _rc {
    display "Note: 'relscore' not found in original"
    gen orig_relscore = .
}

capture rename relscore_cadas orig_relscore_cadas
if _rc {
    display "Note: 'relscore_cadas' not found"
    gen orig_relscore_cadas = .
}

capture rename recall orig_recall
if _rc gen orig_recall = .

capture rename dem1066_score orig_dem1066_score
if _rc gen orig_dem1066_score = .

capture rename dem1066 orig_dem1066
if _rc gen orig_dem1066 = .

capture rename count orig_count
if _rc gen orig_count = .

capture rename nametot orig_nametot
if _rc gen orig_nametot = .

capture rename misstot orig_misstot
if _rc gen orig_misstot = .

capture rename S orig_S
if _rc gen orig_S = .

capture rename U orig_U
if _rc gen orig_U = .

* Keep only comparison variables
preserve
keep pid orig_* version
tempfile original_results
save `original_results'
restore

display "Original results saved."
display _newline(1)

display "ORIGINAL SUMMARY:"
summarize orig_cogscore orig_relscore orig_relscore_cadas orig_recall orig_dem1066_score orig_dem1066

*-------------------------------------------------------------------------------
* PART 2: Run the REFACTORED script and save results
*-------------------------------------------------------------------------------

display _newline(2)
display "RUNNING REFACTORED SCRIPT..."
display "--------------------------------------------------------------------------------"

clear all
quietly do "/Users/chrissoria/Documents/Research/1066/CADAS/do/1066_reproduced/1066_master.do"

* Rename refactored variables
rename cogscore refact_cogscore
rename relscore refact_relscore
rename recall refact_recall
rename dem1066_score refact_dem1066_score
rename dem1066 refact_dem1066
rename count refact_count
rename nametot refact_nametot
rename misstot refact_misstot
rename S refact_S
rename U refact_U

display "REFACTORED SUMMARY:"
summarize refact_cogscore refact_relscore refact_recall refact_dem1066_score refact_dem1066

*-------------------------------------------------------------------------------
* PART 3: Merge and compare
*-------------------------------------------------------------------------------

display _newline(2)
display "MERGING AND COMPARING..."
display "--------------------------------------------------------------------------------"

merge 1:1 pid using `original_results', nogen

* Calculate differences
gen diff_cogscore = refact_cogscore - orig_cogscore
gen diff_relscore = refact_relscore - orig_relscore
gen diff_relscore_vs_cadas = refact_relscore - orig_relscore_cadas
gen diff_recall = refact_recall - orig_recall
gen diff_dem1066_score = refact_dem1066_score - orig_dem1066_score
gen diff_dem1066 = refact_dem1066 - orig_dem1066
gen diff_count = refact_count - orig_count
gen diff_nametot = refact_nametot - orig_nametot
gen diff_misstot = refact_misstot - orig_misstot
gen diff_S = refact_S - orig_S
gen diff_U = refact_U - orig_U

display _newline(2)
display "================================================================================"
display "COMPARISON RESULTS"
display "================================================================================"

display _newline(1)
display "COGSCORE COMPARISON:"
summarize orig_cogscore refact_cogscore diff_cogscore
count if abs(diff_cogscore) > 0.0001 & !missing(diff_cogscore)
display "Cases with cogscore difference: " r(N)

display _newline(1)
display "RELSCORE COMPARISON (refactored vs original 'relscore'):"
summarize orig_relscore refact_relscore diff_relscore
count if abs(diff_relscore) > 0.0001 & !missing(diff_relscore)
display "Cases with relscore difference: " r(N)

display _newline(1)
display "RELSCORE COMPARISON (refactored vs original 'relscore_cadas'):"
display "NOTE: relscore_cadas is what original COMPUTED but didn't use!"
summarize orig_relscore_cadas refact_relscore diff_relscore_vs_cadas
count if abs(diff_relscore_vs_cadas) > 0.0001 & !missing(diff_relscore_vs_cadas)
display "Cases with difference from relscore_cadas: " r(N)

display _newline(1)
display "RECALL COMPARISON:"
summarize orig_recall refact_recall diff_recall
count if abs(diff_recall) > 0.0001 & !missing(diff_recall)
display "Cases with recall difference: " r(N)

display _newline(1)
display "DEM1066_SCORE COMPARISON:"
summarize orig_dem1066_score refact_dem1066_score diff_dem1066_score
count if abs(diff_dem1066_score) > 0.0001 & !missing(diff_dem1066_score)
display "Cases with dem1066_score difference: " r(N)

display _newline(1)
display "DEM1066 CLASSIFICATION COMPARISON:"
tab orig_dem1066 refact_dem1066, miss
count if diff_dem1066 != 0 & !missing(diff_dem1066)
display "Cases with different classification: " r(N)

display _newline(1)
display "COMPONENT COMPARISONS:"
display "Count difference:"
summarize diff_count
display "Nametot difference:"
summarize diff_nametot
display "Misstot difference:"
summarize diff_misstot
display "S (relscore sum) difference:"
summarize diff_S
display "U (weighting factor) difference:"
summarize diff_U

display _newline(2)
display "================================================================================"
display "KEY FINDING:"
display "================================================================================"
display "The ORIGINAL script computes 'relscore_cadas' but uses pre-existing 'relscore'"
display "from the data file for the algorithm. The REFACTORED version computes 'relscore'"
display "fresh and uses it consistently."
display ""
display "If diff_relscore_vs_cadas is ~0 but diff_relscore is not, the refactored"
display "version is computing correctly but using a different source than original."
display "================================================================================"

capture log close

display _newline(1)
display "Comparison complete. See log file for details."
