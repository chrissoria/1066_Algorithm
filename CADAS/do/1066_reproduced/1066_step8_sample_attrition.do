********************************************************************************
* STEP 8: SAMPLE ATTRITION ANALYSIS
* Track how many cases have complete data at each step of the 1066 algorithm
* Creates a "funnel" showing where cases drop off
********************************************************************************

display _newline(2)
display "================================================================================"
display "SAMPLE ATTRITION ANALYSIS: Who Gets a 10/66 Score?"
display "================================================================================"
display _newline(1)

*-------------------------------------------------------------------------------
* STARTING SAMPLE
*-------------------------------------------------------------------------------

local total_n = _N
display "STARTING SAMPLE: N = " `total_n'
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* COGSCORE COMPONENTS
*-------------------------------------------------------------------------------

display _newline(1)
display "COGSCORE COMPONENTS"
display "--------------------------------------------------------------------------------"

* Count missing for each major component
local components "nametot count animtot wordtot1 wordtot2 papertot storytot"

foreach var of local components {
    quietly count if missing(`var')
    local miss_`var' = r(N)
    local pct_`var' = (`miss_`var'' / `total_n') * 100
    display "  `var': " `miss_`var'' " missing (" %4.1f `pct_`var'' "%)"
}

* Count with complete cogscore
quietly count if !missing(cogscore)
local has_cogscore = r(N)
local pct_cogscore = (`has_cogscore' / `total_n') * 100
display ""
display "  => COMPLETE COGSCORE: " `has_cogscore' " / " `total_n' " (" %4.1f `pct_cogscore' "%)"

*-------------------------------------------------------------------------------
* DETAILED COGSCORE BREAKDOWN: Why is cogscore missing?
*-------------------------------------------------------------------------------

display _newline(1)
display "COGSCORE MISSING BREAKDOWN (for cases with missing cogscore)"
display "--------------------------------------------------------------------------------"

quietly count if missing(cogscore)
local miss_cogscore = r(N)

if `miss_cogscore' > 0 {
    * Check each component for the missing cogscore cases
    display "  Among " `miss_cogscore' " cases with missing cogscore:"

    foreach var of local components {
        quietly count if missing(cogscore) & missing(`var')
        local n = r(N)
        local pct = (`n' / `miss_cogscore') * 100
        display "    - Missing `var': " `n' " (" %4.1f `pct' "%)"
    }
}
else {
    display "  No cases with missing cogscore"
}

*-------------------------------------------------------------------------------
* BINARY ITEM REFUSALS (code 7 → missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "BINARY ITEM REFUSALS (now coded as missing)"
display "--------------------------------------------------------------------------------"

local binary_items "pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point"

local total_refusals = 0
foreach var of local binary_items {
    quietly count if missing(`var')
    local miss = r(N)
    if `miss' > 0 {
        local total_refusals = `total_refusals' + `miss'
        display "  `var': " `miss' " missing"
    }
}
display ""
display "  Total binary item missingness: " `total_refusals' " item-observations"

* Pentagon refusals
quietly count if missing(pentag)
local miss_pentag = r(N)
display "  Pentagon (pentag): " `miss_pentag' " missing"

* Circle refusals
quietly count if missing(circle)
local miss_circle = r(N)
display "  Circle: " `miss_circle' " missing"

* Animals refusals (777)
quietly count if missing(animals)
local miss_animals = r(N)
display "  Animals: " `miss_animals' " missing"

*-------------------------------------------------------------------------------
* RECALL COMPONENT
*-------------------------------------------------------------------------------

display _newline(1)
display "RECALL (DELAYED WORD RECALL)"
display "--------------------------------------------------------------------------------"

quietly count if !missing(recall)
local has_recall = r(N)
local pct_recall = (`has_recall' / `total_n') * 100
display "  Complete recall: " `has_recall' " / " `total_n' " (" %4.1f `pct_recall' "%)"

quietly count if missing(recall)
local miss_recall = r(N)

* Check why recall is missing
if `miss_recall' > 0 {
    display ""
    display "  Among " `miss_recall' " cases with missing recall:"

    capture confirm variable recall_refuse
    if _rc == 0 {
        quietly count if missing(recall) & recall_refuse == 7
        local refused = r(N)
        display "    - Refused (code 7): " `refused'

        quietly count if missing(recall) & recall_refuse != 7 & !missing(recall_refuse)
        local other = r(N)
        display "    - Other reason: " `other'
    }
    else {
        display "    - (recall_refuse variable not available for breakdown)"
    }
}

*-------------------------------------------------------------------------------
* RELSCORE COMPONENT
*-------------------------------------------------------------------------------

display _newline(1)
display "RELSCORE (INFORMANT SCORE)"
display "--------------------------------------------------------------------------------"

quietly count if !missing(relscore)
local has_relscore = r(N)
local pct_relscore = (`has_relscore' / `total_n') * 100
display "  Complete relscore: " `has_relscore' " / " `total_n' " (" %4.1f `pct_relscore' "%)"

* Check missing informant items
capture confirm variable misstot
if _rc == 0 {
    quietly sum misstot
    display "  Mean missing informant items: " %4.2f r(mean) " (of 24)"

    quietly count if misstot > 12
    local high_miss = r(N)
    display "  Cases with >50% missing informant items: " `high_miss'
}

*-------------------------------------------------------------------------------
* FINAL SAMPLE: WHO GETS A DEM1066 SCORE?
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "FINAL SAMPLE FUNNEL"
display "================================================================================"
display ""

* Raw starting N (before duplicate removal)
if $n_cog_raw > 0 {
    display "  Raw Cog.dta observations:           " %6.0f $n_cog_raw
    display "  Duplicates dropped (Cog):           " %6.0f $n_cog_dups_dropped
    display "  Duplicates dropped (Infor merge):   " %6.0f $n_infor_dups_dropped
    display "  Duplicates dropped (Scoring merge): " %6.0f $n_scoring_dups_dropped
    display "  ----------------------------------------"
}

* Starting N (after dedup)
display "  Unique PIDs (after dedup):          " %6.0f `total_n' " (100.0%)"

* Has cogscore
quietly count if !missing(cogscore)
local n1 = r(N)
local p1 = (`n1' / `total_n') * 100
local drop1 = `total_n' - `n1'
display "  After cogscore requirement:         " %6.0f `n1' " (" %4.1f `p1' "%)  [-" `drop1' " dropped]"

* Has cogscore AND relscore
quietly count if !missing(cogscore) & !missing(relscore)
local n2 = r(N)
local p2 = (`n2' / `total_n') * 100
local drop2 = `n1' - `n2'
display "  After relscore requirement:         " %6.0f `n2' " (" %4.1f `p2' "%)  [-" `drop2' " dropped]"

* Has cogscore AND relscore AND recall
quietly count if !missing(cogscore) & !missing(relscore) & !missing(recall)
local n3 = r(N)
local p3 = (`n3' / `total_n') * 100
local drop3 = `n2' - `n3'
display "  After recall requirement:           " %6.0f `n3' " (" %4.1f `p3' "%)  [-" `drop3' " dropped]"

* Has dem1066_score (final check)
quietly count if !missing(dem1066_score)
local n_final = r(N)
local p_final = (`n_final' / `total_n') * 100
display ""
display "  FINAL: Cases with dem1066 score:    " %6.0f `n_final' " (" %4.1f `p_final' "%)"

*-------------------------------------------------------------------------------
* SUMMARY OF ATTRITION REASONS
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "ATTRITION SUMMARY"
display "================================================================================"
display ""

local total_dropped = `total_n' - `n_final'
display "Total cases without dem1066 score: " `total_dropped'
display ""

if `total_dropped' > 0 {
    display "Breakdown of " `total_dropped' " cases without final score:"
    display ""

    * Missing cogscore only
    quietly count if missing(cogscore) & !missing(relscore) & !missing(recall)
    local only_cog = r(N)

    * Missing relscore only
    quietly count if !missing(cogscore) & missing(relscore) & !missing(recall)
    local only_rel = r(N)

    * Missing recall only
    quietly count if !missing(cogscore) & !missing(relscore) & missing(recall)
    local only_rec = r(N)

    * Missing cogscore + relscore
    quietly count if missing(cogscore) & missing(relscore) & !missing(recall)
    local cog_rel = r(N)

    * Missing cogscore + recall
    quietly count if missing(cogscore) & !missing(relscore) & missing(recall)
    local cog_rec = r(N)

    * Missing relscore + recall
    quietly count if !missing(cogscore) & missing(relscore) & missing(recall)
    local rel_rec = r(N)

    * Missing all three
    quietly count if missing(cogscore) & missing(relscore) & missing(recall)
    local all_three = r(N)

    display "  Missing cogscore only:           " %4.0f `only_cog'
    display "  Missing relscore only:           " %4.0f `only_rel'
    display "  Missing recall only:             " %4.0f `only_rec'
    display "  Missing cogscore + relscore:     " %4.0f `cog_rel'
    display "  Missing cogscore + recall:       " %4.0f `cog_rec'
    display "  Missing relscore + recall:       " %4.0f `rel_rec'
    display "  Missing all three:               " %4.0f `all_three'
    display "  --------------------------------"
    local check_total = `only_cog' + `only_rel' + `only_rec' + `cog_rel' + `cog_rec' + `rel_rec' + `all_three'
    display "  Total:                           " %4.0f `check_total'
}

*-------------------------------------------------------------------------------
* DEMENTIA CLASSIFICATION AMONG COMPLETE CASES
*-------------------------------------------------------------------------------

display _newline(1)
display "================================================================================"
display "DEMENTIA CLASSIFICATION (among complete cases)"
display "================================================================================"
display ""

quietly count if dem1066 == 1
local n_dem = r(N)
quietly count if dem1066 == 0
local n_nodem = r(N)
quietly count if !missing(dem1066)
local n_class = r(N)

local prev = (`n_dem' / `n_class') * 100

display "  Dementia (dem1066 = 1):     " %6.0f `n_dem' " (" %4.1f `prev' "%)"
display "  No dementia (dem1066 = 0):  " %6.0f `n_nodem' " (" %4.1f 100 - `prev' "%)"
display "  Total classified:           " %6.0f `n_class'

*-------------------------------------------------------------------------------
* EXPORT ATTRITION SUMMARY TO CSV
*-------------------------------------------------------------------------------

display _newline(1)
display "Exporting attrition summary to CSV..."

* Create a temporary dataset for export
preserve
clear

* Set up the data structure
set obs 15

* Create variables
gen str60 category = ""
gen str60 subcategory = ""
gen n = .
gen pct = .

* Row 1: Starting sample
replace category = "Starting Sample" in 1
replace subcategory = "Total observations" in 1
replace n = `total_n' in 1
replace pct = 100 in 1

* Row 2-4: After each requirement
replace category = "After Requirements" in 2
replace subcategory = "After cogscore requirement" in 2
replace n = `n1' in 2
replace pct = `p1' in 2

replace category = "After Requirements" in 3
replace subcategory = "After relscore requirement" in 3
replace n = `n2' in 3
replace pct = `p2' in 3

replace category = "After Requirements" in 4
replace subcategory = "After recall requirement" in 4
replace n = `n3' in 4
replace pct = `p3' in 4

* Row 5: Final
replace category = "Final Sample" in 5
replace subcategory = "Cases with dem1066 score" in 5
replace n = `n_final' in 5
replace pct = `p_final' in 5

* Row 6: Total dropped
replace category = "Attrition Summary" in 6
replace subcategory = "Total cases dropped" in 6
replace n = `total_dropped' in 6
replace pct = (`total_dropped' / `total_n') * 100 in 6

* Rows 7-13: Breakdown of why dropped
replace category = "Why Cases Drop Off" in 7
replace subcategory = "Missing cogscore only (any component missing)" in 7
replace n = `only_cog' in 7

replace category = "Why Cases Drop Off" in 8
replace subcategory = "Missing relscore only (>50% informant items missing)" in 8
replace n = `only_rel' in 8

replace category = "Why Cases Drop Off" in 9
replace subcategory = "Missing recall only" in 9
replace n = `only_rec' in 9

replace category = "Why Cases Drop Off" in 10
replace subcategory = "Missing cogscore (any component) + relscore (>50% informant)" in 10
replace n = `cog_rel' in 10

replace category = "Why Cases Drop Off" in 11
replace subcategory = "Missing cogscore (any component) + recall" in 11
replace n = `cog_rec' in 11

replace category = "Why Cases Drop Off" in 12
replace subcategory = "Missing relscore (>50% informant missing) + recall" in 12
replace n = `rel_rec' in 12

replace category = "Why Cases Drop Off" in 13
replace subcategory = "Missing all three" in 13
replace n = `all_three' in 13

* Row 14-15: Final classification
replace category = "Dementia Classification" in 14
replace subcategory = "Dementia (dem1066 = 1)" in 14
replace n = `n_dem' in 14
replace pct = `prev' in 14

replace category = "Dementia Classification" in 15
replace subcategory = "No dementia (dem1066 = 0)" in 15
replace n = `n_nodem' in 15
replace pct = 100 - `prev' in 15

* Export to CSV (save to 1066_diagnostics subfolder)
capture mkdir "1066_diagnostics"
export delimited using "1066_diagnostics/1066_algo_sample_attrition.csv", replace

* Also copy to Google Drive
if $country == 1 {
    if `"$language"' == "E" {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/Rep Dom/latest_data/TRANSLATED/1066_DIAGNOSTIC_EXCELS"
    }
    else {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/Rep Dom/latest_data/1066_DIAGNOSTIC_EXCELS"
    }
}
else if $country == 2 {
    if `"$language"' == "E" {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/cuba/latest_data/TRANSLATED/1066_DIAGNOSTIC_EXCELS"
    }
    else {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/cuba/latest_data/1066_DIAGNOSTIC_EXCELS"
    }
}
capture mkdir "`gdrive_path'"
capture export delimited using "`gdrive_path'/1066_algo_sample_attrition.csv", replace

display "  Saved to: 1066_diagnostics/1066_algo_sample_attrition.csv"
display "  Also saved to: Google Drive 1066_DIAGNOSTIC_EXCELS/"

restore

display _newline(1)
display "================================================================================"
display "STEP 8 complete: Sample attrition analysis."
display "================================================================================"
