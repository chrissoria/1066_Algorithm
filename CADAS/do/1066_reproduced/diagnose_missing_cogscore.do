********************************************************************************
* DIAGNOSE MISSING COGSCORE
* Run after 1066_master.do to identify what's driving missing cogscores
********************************************************************************

display _newline(2)
display "================================================================================"
display "COGSCORE MISSING DIAGNOSTICS"
display "================================================================================"

* Total missing
quietly count if missing(cogscore)
local miss_total = r(N)
quietly count
local n_total = r(N)
display "Total observations: `n_total'"
display "Missing cogscore: `miss_total'"
display ""

* Component-level breakdown
display "--- COMPONENT-LEVEL MISSING (among missing cogscore cases) ---"
foreach var in nametot count animtot wordtot1 wordtot2 papertot storytot {
    quietly count if missing(cogscore) & missing(`var')
    local n = r(N)
    display "  `var': `n' missing"
}

* Now drill into source variables for each component
display ""
display "--- SOURCE VARIABLE DRILL-DOWN (among ALL observations) ---"

display ""
display "NAMETOT sources (name, nrecall):"
foreach var in name nrecall {
    quietly count if missing(`var')
    display "  `var': " r(N) " missing"
}

display ""
display "COUNT sources (26 binary items):"
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag {
    quietly count if missing(`var')
    if r(N) > 0 {
        display "  `var': " r(N) " missing"
    }
}
quietly {
    local any_count_miss = 0
    foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag {
        count if missing(`var')
        if r(N) > 0 local any_count_miss = 1
    }
}
if `any_count_miss' == 0 display "  (none missing)"

display ""
display "ANIMTOT source (animals):"
quietly count if missing(animals)
display "  animals: " r(N) " missing"

display ""
display "WORDTOT1 sources (wordimm <- c_11, c_12, c_13):"
foreach var in wordimm {
    quietly count if missing(`var')
    display "  `var': " r(N) " missing"
}

display ""
display "WORDTOT2 sources (worddel <- c_21, c_22, c_23):"
foreach var in worddel {
    quietly count if missing(`var')
    display "  `var': " r(N) " missing"
}

display ""
display "PAPERTOT source (paper <- c_27, c_28, c_29):"
foreach var in paper {
    quietly count if missing(`var')
    display "  `var': " r(N) " missing"
}

display ""
display "STORYTOT source (story <- c_66a-f):"
capture quietly count if missing(storytot_recoded)
if _rc == 0 {
    display "  storytot_recoded: " r(N) " missing (after imputation)"
}
quietly count if missing(storytot)
display "  storytot: " r(N) " missing (before imputation)"
quietly count if missing(story)
display "  story: " r(N) " missing"

display ""
display "RECALL (enters logistic directly, not part of cogscore):"
quietly count if missing(recall)
display "  recall: " r(N) " missing"

display ""
display "================================================================================"
display "CROSS-TAB: How many components missing per case (among missing cogscore)"
display "================================================================================"

quietly {
    gen _n_miss_components = 0
    foreach var in nametot count animtot wordtot1 wordtot2 papertot storytot {
        replace _n_miss_components = _n_miss_components + missing(`var')
    }
}
tab _n_miss_components if missing(cogscore)
drop _n_miss_components

display ""
display "================================================================================"
display "ALL cases with missing cogscore (globalrecordid + pid + components)"
display "================================================================================"
list globalrecordid pid nametot count animtot wordtot1 wordtot2 papertot storytot recall if missing(cogscore), noobs abbreviate(16)

* Export to duplicates folder
display ""
preserve
keep if missing(cogscore)
keep globalrecordid pid nametot count animtot wordtot1 wordtot2 papertot storytot recall
capture export excel using "$data_path/duplicates/missing_cogscore.xlsx", replace firstrow(variables)
if _rc == 0 {
    display "Exported to: $data_path/duplicates/missing_cogscore.xlsx"
}
else {
    display "No cases to export or export failed (rc = " _rc ")"
}
restore
