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

* Handle duplicates by keeping first occurrence
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

display "Loaded Cog.dta: " _N " observations"

*-------------------------------------------------------------------------------
* MERGE INFORMANT DATA
*-------------------------------------------------------------------------------

merge 1:m pid using Infor, force

* Handle duplicates after merge
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup
rename _merge merge1

display "After merging Infor.dta: " _N " observations"

*-------------------------------------------------------------------------------
* MERGE COGNITIVE SCORING DATA
*-------------------------------------------------------------------------------

merge 1:m pid using Cog_Scoring, force

* Handle duplicates after merge
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

display "After merging Cog_Scoring.dta: " _N " observations"

duplicates report pid

display "STEP 0 complete: Data loaded and merged."
display "--------------------------------------------------------------------------------"
