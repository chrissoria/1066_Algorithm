clear all
set more off
capture log close _all
cls

*******ADJUST GLOBALS HERE**********

***********************************
global country "CU" // change to "CU" or "DR"
global drop_missing_from_relscore "no" // change to yes or no
global drop_physical_disability "no"
global impute_recall "yes" //imputes the 10-word delayed recall from the immediate recall questions

global base_path "/Users/chrissoria/Documents/Research/1066"
global within_path "$base_path/CADAS/do/cadas_within"
global log_path "$within_path/logs"
global plot_path "$within_path/plots"

* Create directories if they don't exist
capture mkdir "$log_path"
capture mkdir "$plot_path"

***** SCRIPT STARTS HERE *********

**********************************

do "$within_path/cadas_within_step0_setup.do"
do "$within_path/cadas_within_step0.5_create_vars.do"
do "$within_path/cadas_within_step1_interaction.do"
do "$within_path/cadas_within_step2_varselect.do"
do "$within_path/cadas_within_step3_structure.do"
do "$within_path/cadas_within_step4_sample.do"
do "$within_path/cadas_within_step5_modeling.do"
do "$within_path/cadas_within_step6_evaluation.do"
