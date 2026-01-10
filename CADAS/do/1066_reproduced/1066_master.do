********************************************************************************
* 10/66 DEMENTIA ALGORITHM - MASTER FILE
* Orchestrates all steps for computing the 10/66 dementia classification
********************************************************************************

clear all
set more off
capture log close
cls

*-------------------------------------------------------------------------------
* USER AND COUNTRY CONFIGURATION (uses CADAS include files)
*-------------------------------------------------------------------------------

capture include "/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_user_define.do"
capture include "C:\Users\Ty\Desktop\CADAS Data do files\CADAS_user_define.do"

if `"`user'"' == "Chris" {
    local path = "/Users/chrissoria/Documents/CADAS/Data"
    include "/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_country_define.do"
    global country = `country'

    if `country' == 0 {
        global data_path "`path'/PR_out"
    }
    else if `country' == 1 {
        global data_path "`path'/DR_out"
    }
    else if `country' == 2 {
        global data_path "`path'/CUBA_out"
    }

    global script_path "/Users/chrissoria/Documents/CADAS/do/1066_reproduced"
}

else if `"`user'"' == "Ty" {
    local path = "C:\Users\Ty\Desktop\Stata_CADAS\DATA"
    include "C:\Users\Ty\Desktop\CADAS Data do files\CADAS_country_define.do"
    global country = `country'

    if `country' == 0 {
        global data_path "`path'/PR_out"
    }
    else if `country' == 1 {
        global data_path "`path'/DR_out"
    }
    else if `country' == 2 {
        global data_path "`path'/CUBA_out"
    }

    global script_path "C:\Users\Ty\Desktop\CADAS Data do files\1066_reproduced"
}

cd "$data_path"
local current_dir : pwd
display "Working directory: `current_dir'"

*-------------------------------------------------------------------------------
* ALGORITHM OPTIONS
*-------------------------------------------------------------------------------

global drop_missing_from_relscore "no"   // Drop cases with missing relscore items
global impute_recall "no"                 // Impute delayed recall from immediate
global use_strict_pentag "no"           // Pentagon scoring: "yes" = only value 2 correct, "no" = 1 and 2 both correct

* NOTE: Disability vs refusal codes are now handled separately in step1:
*   - Disability codes (6, 8, 9 = could not) → recoded to 0
*   - Refusal codes (7 = refused) → recoded to missing

*-------------------------------------------------------------------------------
* EXECUTE STEPS
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "10/66 DEMENTIA ALGORITHM"
display "================================================================================"
display _newline(1)

* Step 0: Load and merge data
do "$script_path/1066_step0_data_load.do"

* Step 1: Prepare cognitive score components (variable renaming and recoding)
do "$script_path/1066_step1_cogscore_prep.do"

* Step 2: Calculate COGSCORE
do "$script_path/1066_step2_cogscore.do"

* Step 3: Prepare relative/informant score components
do "$script_path/1066_step3_relscore_prep.do"

* Step 4: Calculate RELSCORE
do "$script_path/1066_step4_relscore.do"

* Step 5: Apply 10/66 classification algorithm
do "$script_path/1066_step5_classify.do"

* Step 6: Save output
do "$script_path/1066_step6_save.do"

* Step 7: Validate against 1066 baseline (optional comparison)
do "$script_path/1066_step7_validate_vs_baseline.do"

* Step 8: Sample attrition analysis (shows where cases drop off)
do "$script_path/1066_step8_sample_attrition.do"

*-------------------------------------------------------------------------------
* FINAL SUMMARY
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
display "FINAL SUMMARY"
display "================================================================================"
display _newline(1)

display "COGSCORE:"
summarize cogscore

display _newline(1)
display "RELSCORE:"
summarize relscore

display _newline(1)
display "RECALL:"
summarize recall

display _newline(1)
display "DEMENTIA CLASSIFICATION (dem1066):"
tab dem1066, miss

display _newline(1)
display "Algorithm complete. Data saved to 1066.dta"
display "================================================================================"
