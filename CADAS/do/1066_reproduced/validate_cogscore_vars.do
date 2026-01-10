********************************************************************************
* VALIDATE COGSCORE VARIABLES
* Check that all cogscore component variables have valid values
* Run this AFTER running 1066_master.do, or it will load from saved 1066.dta
********************************************************************************

* Load the 1066 data if not already in memory
capture confirm variable cogscore
if _rc {
    display "Loading 1066.dta..."
    use "1066.dta", clear
}

display _newline(2)
display "================================================================================"
display "VALIDATING COGSCORE COMPONENT VARIABLES"
display "================================================================================"

local has_errors = 0

*-------------------------------------------------------------------------------
* BINARY ITEMS (should be 0, 1, or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "1. BINARY ITEMS (should be 0, 1, or missing):"
display "--------------------------------------------------------------------------------"

local binary_items "pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag"

foreach var of local binary_items {
    capture confirm variable `var'
    if _rc {
        display "   `var': VARIABLE NOT FOUND"
        local has_errors = 1
    }
    else {
        quietly count if `var' != 0 & `var' != 1 & !missing(`var')
        local bad_count = r(N)
        if `bad_count' > 0 {
            display "   `var': " `bad_count' " cases with invalid values (not 0, 1, or missing)"
            tab `var' if `var' != 0 & `var' != 1 & !missing(`var')
            local has_errors = 1
        }
        else {
            display "   `var': OK"
        }
    }
}

*-------------------------------------------------------------------------------
* NAMETOT (should be 0 or 1)
*-------------------------------------------------------------------------------

display _newline(1)
display "2. NAMETOT (should be 0 or 1):"
display "--------------------------------------------------------------------------------"

quietly count if nametot != 0 & nametot != 1 & !missing(nametot)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   nametot: " `bad_count' " cases with invalid values"
    tab nametot if nametot != 0 & nametot != 1 & !missing(nametot)
    local has_errors = 1
}
else {
    display "   nametot: OK"
}

*-------------------------------------------------------------------------------
* ANIMALS (should be 0-45 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "3. ANIMALS (should be 0-45 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (animals < 0 | animals > 45) & !missing(animals)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   animals: " `bad_count' " cases with invalid values"
    tab animals if (animals < 0 | animals > 45) & !missing(animals)
    local has_errors = 1
}
else {
    display "   animals: OK"
}

*-------------------------------------------------------------------------------
* WORDIMM (should be 0-3 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "4. WORDIMM (should be 0-3 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (wordimm < 0 | wordimm > 3) & !missing(wordimm)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   wordimm: " `bad_count' " cases with invalid values"
    tab wordimm if (wordimm < 0 | wordimm > 3) & !missing(wordimm)
    local has_errors = 1
}
else {
    display "   wordimm: OK"
}

*-------------------------------------------------------------------------------
* WORDDEL (should be 0-3 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "5. WORDDEL (should be 0-3 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (worddel < 0 | worddel > 3) & !missing(worddel)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   worddel: " `bad_count' " cases with invalid values"
    tab worddel if (worddel < 0 | worddel > 3) & !missing(worddel)
    local has_errors = 1
}
else {
    display "   worddel: OK"
}

*-------------------------------------------------------------------------------
* PAPER (should be 0-3 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "6. PAPER (should be 0-3 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (paper < 0 | paper > 3) & !missing(paper)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   paper: " `bad_count' " cases with invalid values"
    tab paper if (paper < 0 | paper > 3) & !missing(paper)
    local has_errors = 1
}
else {
    display "   paper: OK"
}

*-------------------------------------------------------------------------------
* STORY (should be 0-6 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "7. STORY (should be 0-6 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (story < 0 | story > 6) & !missing(story)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   story: " `bad_count' " cases with invalid values"
    tab story if (story < 0 | story > 6) & !missing(story)
    local has_errors = 1
}
else {
    display "   story: OK"
}

*-------------------------------------------------------------------------------
* COUNT (should be 0-28 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "8. COUNT (should be 0-28 or missing):"
display "--------------------------------------------------------------------------------"

quietly count if (count < 0 | count > 28) & !missing(count)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   count: " `bad_count' " cases with invalid values"
    tab count if (count < 0 | count > 28) & !missing(count)
    local has_errors = 1
}
else {
    display "   count: OK"
}

*-------------------------------------------------------------------------------
* NORMALIZED SCORES (should be 0-1 or missing)
*-------------------------------------------------------------------------------

display _newline(1)
display "9. NORMALIZED SCORES:"
display "--------------------------------------------------------------------------------"

* animtot can exceed 1 (animals can be > 23, divided by 23)
display "   animtot (animals/23, can exceed 1 if animals > 23):"
summarize animtot

* Other normalized scores should be 0-1
foreach var in wordtot1 wordtot2 papertot storytot {
    capture confirm variable `var'
    if _rc {
        display "   `var': VARIABLE NOT FOUND"
        local has_errors = 1
    }
    else {
        quietly count if (`var' < 0 | `var' > 1) & !missing(`var')
        local bad_count = r(N)
        if `bad_count' > 0 {
            display "   `var': " `bad_count' " cases with invalid values"
            summarize `var' if (`var' < 0 | `var' > 1) & !missing(`var')
            local has_errors = 1
        }
        else {
            display "   `var': OK"
        }
    }
}

*-------------------------------------------------------------------------------
* COGSCORE (should be 0-33 approximately)
*-------------------------------------------------------------------------------

display _newline(1)
display "10. COGSCORE (should be ~0-33):"
display "--------------------------------------------------------------------------------"

quietly count if (cogscore < 0 | cogscore > 35) & !missing(cogscore)
local bad_count = r(N)
if `bad_count' > 0 {
    display "   cogscore: " `bad_count' " cases with suspicious values"
    summarize cogscore if (cogscore < 0 | cogscore > 35) & !missing(cogscore)
    local has_errors = 1
}
else {
    display "   cogscore: OK"
    summarize cogscore
}

*-------------------------------------------------------------------------------
* SUMMARY
*-------------------------------------------------------------------------------

display _newline(2)
display "================================================================================"
if `has_errors' == 1 {
    display "VALIDATION COMPLETE: ERRORS FOUND - review output above"
}
else {
    display "VALIDATION COMPLETE: ALL VARIABLES OK"
}
display "================================================================================"
