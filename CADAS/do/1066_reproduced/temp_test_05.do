clear all
set more off
capture log close
capture cls

capture include "/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_user_define.do"

if `"`user'"' == "Chris" {
    local path = "/Users/chrissoria/Documents/CADAS/Data"

    * Force Cuba for this test
    global country = 2
    local country = 2

    if `country' == 0 {
        global data_path "`path'/PR_out"
    }
    else if `country' == 1 {
        global data_path "`path'/DR_out"
    }
    else if `country' == 2 {
        global data_path "`path'/CUBA_out"
    }

    global script_path "/Users/chrissoria/Documents/CADAS/Do/1066_reproduced"
}

cd "$data_path"
display "Working directory: `c(pwd)'"
display "Country: $country"

global run_pre_prep "yes"

* Step 0: Load and merge data
do "$script_path/1066_step0_data_load.do"

* Step 0.5: Pre-preparation
do "$script_path/1066_step05_pre_prep_cog_vars.do"

display _newline(1)
display "Test complete."
