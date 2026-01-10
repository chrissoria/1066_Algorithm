********************************************************************************
* STEP 0: DATA LOADING
* Load and merge Cog, Infor, and Cog_Scoring datasets
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 0: Loading and merging data..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* LOAD COGNITIVE DATA
*-------------------------------------------------------------------------------

use Cog, clear
local n_cog_raw = _N

* Handle duplicates by keeping first occurrence
duplicates tag pid, gen(dup_tag)
quietly count if dup_tag > 0
local n_cog_dups = r(N)
drop dup_tag

sort pid
by pid: gen dup = _n == 1
quietly count if dup == 0
local n_cog_dropped = r(N)
drop if dup == 0
drop dup

display "Loaded Cog.dta:"
display "  Raw observations:      " %6.0f `n_cog_raw'
display "  Duplicate PIDs:        " %6.0f `n_cog_dups' " (in " %3.0f `n_cog_dropped' " extra rows)"
display "  After dedup:           " %6.0f _N

*-------------------------------------------------------------------------------
* MERGE INFORMANT DATA
*-------------------------------------------------------------------------------

local n_before_infor = _N
merge 1:m pid using Infor, force

* Handle duplicates after merge
duplicates tag pid, gen(dup_tag)
quietly count if dup_tag > 0
local n_infor_dups = r(N)
drop dup_tag

sort pid
by pid: gen dup = _n == 1
quietly count if dup == 0
local n_infor_dropped = r(N)
drop if dup == 0
drop dup
rename _merge merge1

display ""
display "After merging Infor.dta:"
display "  Before merge:          " %6.0f `n_before_infor'
display "  Duplicate PIDs:        " %6.0f `n_infor_dups' " (dropped " %3.0f `n_infor_dropped' " extra rows)"
display "  After dedup:           " %6.0f _N

*-------------------------------------------------------------------------------
* MERGE COGNITIVE SCORING DATA
*-------------------------------------------------------------------------------

local n_before_scoring = _N
merge 1:m pid using Cog_Scoring, force

* Handle duplicates after merge
duplicates tag pid, gen(dup_tag)
quietly count if dup_tag > 0
local n_scoring_dups = r(N)
drop dup_tag

sort pid
by pid: gen dup = _n == 1
quietly count if dup == 0
local n_scoring_dropped = r(N)
drop if dup == 0
drop dup

display ""
display "After merging Cog_Scoring.dta:"
display "  Before merge:          " %6.0f `n_before_scoring'
display "  Duplicate PIDs:        " %6.0f `n_scoring_dups' " (dropped " %3.0f `n_scoring_dropped' " extra rows)"
display "  After dedup:           " %6.0f _N

*-------------------------------------------------------------------------------
* SUMMARY
*-------------------------------------------------------------------------------

display ""
display "DUPLICATE SUMMARY:"
local total_dups_dropped = `n_cog_dropped' + `n_infor_dropped' + `n_scoring_dropped'
display "  Total duplicate rows dropped: " %6.0f `total_dups_dropped'
display "  Final unique PIDs:            " %6.0f _N

* Store for use in step 8 attrition report
global n_cog_raw = `n_cog_raw'
global n_cog_dups_dropped = `n_cog_dropped'
global n_infor_dups_dropped = `n_infor_dropped'
global n_scoring_dups_dropped = `n_scoring_dropped'
global n_total_dups_dropped = `total_dups_dropped'

duplicates report pid

display ""
display "STEP 0 complete: Data loaded and merged."
display "--------------------------------------------------------------------------------"
