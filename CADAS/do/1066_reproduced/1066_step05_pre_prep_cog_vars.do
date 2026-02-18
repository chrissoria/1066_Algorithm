********************************************************************************
* STEP .5: COGSCORE PRE-PREPARATION
* Recode all cogscore vars so that missing is 0
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP .5: restructuring cogscore variables to reclassify missing to 0..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* OBJECT NAMING ITEMS: recode missing to 0
* (c_24=pencil, c_25=watch, c_48=chair, c_49=shoes, c_50=knuckle,
*  c_51=elbow, c_52=should, c_53=bridge, c_54=hammer, c_55=pray, c_56=chemist)
*-------------------------------------------------------------------------------

foreach var in c_24 c_25 c_48 c_49 c_50 c_51 c_52 c_53 c_54 c_55 c_56 c_26 c_8 {
    gen `var'_recoded = `var'
    replace `var'_recoded = 0 if missing(`var'_recoded)
    replace `var'_recoded = 0 if `var'_recoded == 6
    replace `var'_recoded = 0 if `var'_recoded == 7
	replace `var'_recoded = 0 if `var'_recoded == 8
	replace `var'_recoded = 0 if `var'_recoded == 9
    replace `var'_recoded = . if `var'_recoded == 11
}

*-------------------------------------------------------------------------------
* CHIEF/PRESIDENT NAMING (country-specific): recode missing/refusal to 0
*-------------------------------------------------------------------------------

if $country == 0 {
    gen c_70_p_recoded = c_70_p
    replace c_70_p_recoded = 0 if missing(c_70_p_recoded)
    replace c_70_p_recoded = 0 if c_70_p_recoded == 6
    replace c_70_p_recoded = 0 if c_70_p_recoded == 7
	replace c_70_p_recoded = 0 if c_70_p_recoded == 8
	replace c_70_p_recoded = 0 if c_70_p_recoded == 9
    replace c_70_p_recoded = . if c_70_p_recoded == 11
}
else {
    gen c_70_d_c_recoded = c_70_d_c
    replace c_70_d_c_recoded = 0 if missing(c_70_d_c_recoded)
    replace c_70_d_c_recoded = 0 if c_70_d_c_recoded == 6
    replace c_70_d_c_recoded = 0 if c_70_d_c_recoded == 7
	replace c_70_d_c_recoded = 0 if c_70_d_c_recoded == 8
	replace c_70_d_c_recoded = 0 if c_70_d_c_recoded == 9
    replace c_70_d_c_recoded = . if c_70_d_c_recoded == 11
}

*-------------------------------------------------------------------------------
* COMPARE ORIGINAL vs RECODED
*-------------------------------------------------------------------------------

foreach var in c_24 c_25 c_48 c_49 c_50 c_51 c_52 c_53 c_54 c_55 c_56 c_26 c_8 {
    display _newline(1)
    display "--- `var' (original) ---"
    tab `var', miss
    display "--- `var'_recoded ---"
    tab `var'_recoded, miss
}

* Chief/president naming
if $country == 0 {
    display _newline(1)
    display "--- c_70_p (original) ---"
    tab c_70_p, miss
    display "--- c_70_p_recoded ---"
    tab c_70_p_recoded, miss
}
else {
    display _newline(1)
    display "--- c_70_d_c (original) ---"
    tab c_70_d_c, miss
    display "--- c_70_d_c_recoded ---"
    tab c_70_d_c_recoded, miss
}

*-------------------------------------------------------------------------------
* INFORMANT SOURCED VARS: recode missing/refusal to 0
* (i_a2=street, i_a3=store, i_a4=address)
*-------------------------------------------------------------------------------

foreach var in i_a2 i_a3 i_a4 {
    gen `var'_recoded = `var'
    replace `var'_recoded = 0 if missing(`var'_recoded)
    replace `var'_recoded = 0 if `var'_recoded == 6
    replace `var'_recoded = 0 if `var'_recoded == 7
    replace `var'_recoded = 0 if `var'_recoded == 8 | `var'_recoded == 9
    replace `var'_recoded = . if `var'_recoded == 11
}

* Compare original vs recoded
foreach var in i_a2 i_a3 i_a4 {
    display _newline(1)
    display "--- `var' (original) ---"
    tab `var', miss
    display "--- `var'_recoded ---"
    tab `var'_recoded, miss
}

*-------------------------------------------------------------------------------
* ORIENTATION - TIME: recode missing/refusal/disability to 0
* (c_3=month, c_5=day, c_1=year)
*-------------------------------------------------------------------------------

foreach var in c_3 c_5 c_1 {
    gen `var'_recoded = `var'
    replace `var'_recoded = 0 if missing(`var'_recoded)
    replace `var'_recoded = 0 if `var'_recoded == 6
    replace `var'_recoded = 0 if `var'_recoded == 7
    replace `var'_recoded = 0 if `var'_recoded == 8 | `var'_recoded == 9
    replace `var'_recoded = . if `var'_recoded == 11
}

foreach var in c_3 c_5 c_1 {
    display _newline(1)
    display "--- `var' (original) ---"
    tab `var', miss
    display "--- `var'_recoded ---"
    tab `var'_recoded, miss
}

*-------------------------------------------------------------------------------
* SEASON (country-specific): recode missing/refusal/disability to 0
* PR/Cuba: c_2_p_c; DR: c_2_p_c + c_2_d
*-------------------------------------------------------------------------------

gen c_2_p_c_recoded = c_2_p_c
replace c_2_p_c_recoded = 0 if missing(c_2_p_c_recoded)
replace c_2_p_c_recoded = 0 if c_2_p_c_recoded == 6
replace c_2_p_c_recoded = 0 if c_2_p_c_recoded == 7
replace c_2_p_c_recoded = 0 if c_2_p_c_recoded == 8 | c_2_p_c_recoded == 9
replace c_2_p_c_recoded = . if c_2_p_c_recoded == 11

display _newline(1)
display "--- c_2_p_c (original) ---"
tab c_2_p_c, miss
display "--- c_2_p_c_recoded ---"
tab c_2_p_c_recoded, miss

if $country == 1 {
    gen c_2_d_recoded = c_2_d
    replace c_2_d_recoded = 0 if missing(c_2_d_recoded)
    replace c_2_d_recoded = 0 if c_2_d_recoded == 6
    replace c_2_d_recoded = 0 if c_2_d_recoded == 7
    replace c_2_d_recoded = 0 if c_2_d_recoded == 8 | c_2_d_recoded == 9
    replace c_2_d_recoded = . if c_2_d_recoded == 11

    display _newline(1)
    display "--- c_2_d (original) ---"
    tab c_2_d, miss
    display "--- c_2_d_recoded ---"
    tab c_2_d_recoded, miss
}

*-------------------------------------------------------------------------------
* MOTOR COMMANDS: recode missing/refusal/disability to 0
* (c_61=nod, c_62=point)
*-------------------------------------------------------------------------------

foreach var in c_61 c_62 {
    gen `var'_recoded = `var'
    replace `var'_recoded = 0 if missing(`var'_recoded)
    replace `var'_recoded = 0 if `var'_recoded == 6
    replace `var'_recoded = 0 if `var'_recoded == 7
    replace `var'_recoded = 0 if `var'_recoded == 8 | `var'_recoded == 9
    replace `var'_recoded = . if `var'_recoded == 11
}

foreach var in c_61 c_62 {
    display _newline(1)
    display "--- `var' (original) ---"
    tab `var', miss
    display "--- `var'_recoded ---"
    tab `var'_recoded, miss
}

*-------------------------------------------------------------------------------
* LONG-TERM MEMORY (country-specific): recode missing/refusal/disability to 0
* PR: c_69_p; Cuba/DR: c_69_c + c_69_d
*-------------------------------------------------------------------------------

if $country == 0 {
    gen c_69_p_recoded = c_69_p
    replace c_69_p_recoded = 0 if missing(c_69_p_recoded)
    replace c_69_p_recoded = 0 if c_69_p_recoded == 6
    replace c_69_p_recoded = 0 if c_69_p_recoded == 7
    replace c_69_p_recoded = 0 if c_69_p_recoded == 8 | c_69_p_recoded == 9
    replace c_69_p_recoded = . if c_69_p_recoded == 11

    display _newline(1)
    display "--- c_69_p (original) ---"
    tab c_69_p, miss
    display "--- c_69_p_recoded ---"
    tab c_69_p_recoded, miss
}
else {
    foreach var in c_69_c c_69_d {
        gen `var'_recoded = `var'
        replace `var'_recoded = 0 if missing(`var'_recoded)
        replace `var'_recoded = 0 if `var'_recoded == 6
        replace `var'_recoded = 0 if `var'_recoded == 7
        replace `var'_recoded = 0 if `var'_recoded == 8 | `var'_recoded == 9
        replace `var'_recoded = . if `var'_recoded == 11
    }

    foreach var in c_69_c c_69_d {
        display _newline(1)
        display "--- `var' (original) ---"
        tab `var', miss
        display "--- `var'_recoded ---"
        tab `var'_recoded, miss
    }
}

*-------------------------------------------------------------------------------
* CIRCLE DRAWING (cs_72_1): imputation for missing values
* Step 1: Clean bad values (5, 23 = typos → missing)
* Step 2: Regress cs_72_1 on cs_32 cs_72* using non-missing cases
* Step 3: Predict missing cs_72_1 from model
* Fallback: If c_72_1 also missing, use i_f_csid_15 + i_f_csid_16
*-------------------------------------------------------------------------------

gen cs_72_1_recoded = cs_72_1

* Clean typos
replace cs_72_1_recoded = . if cs_72_1_recoded == 5
replace cs_72_1_recoded = . if cs_72_1_recoded == 23
replace cs_72_1_recoded = . if cs_72_1_recoded == 11

display _newline(1)
display "--- cs_72_1 (original) ---"
tab cs_72_1, miss
display "--- cs_72_1_recoded (after cleaning, before imputation) ---"
tab cs_72_1_recoded, miss

* Primary imputation: regress on cs_32 and cs_72* (country-specific)
display _newline(1)
display "Circle imputation model (primary):"
xi: reg cs_72_1_recoded cs_32 cs_72_2 cs_72_3 cs_72_4
predict cs_72_1_pred
quietly count if missing(cs_72_1_recoded) & !missing(cs_72_1_pred)
local n_imputed_primary = r(N)
replace cs_72_1_recoded = cs_72_1_pred if missing(cs_72_1_recoded)
display "  Primary imputation filled: `n_imputed_primary' obs"

* Fallback imputation: use CSID 15 and 16 for remaining missing
quietly count if missing(cs_72_1_recoded)
local n_still_missing = r(N)
if `n_still_missing' > 0 {
    display _newline(1)
    display "Circle imputation model (fallback - CSID 15 & 16):"
    xi: reg cs_72_1 i.i_f_csid_15 i.i_f_csid_16
    predict cs_72_1_pred2
    quietly count if missing(cs_72_1_recoded) & !missing(cs_72_1_pred2)
    local n_imputed_fallback = r(N)
    replace cs_72_1_recoded = cs_72_1_pred2 if missing(cs_72_1_recoded)
    display "  Fallback imputation filled: `n_imputed_fallback' obs"
    drop cs_72_1_pred2
}

drop cs_72_1_pred

display "--- cs_72_1_recoded (after imputation) ---"
tab cs_72_1_recoded, miss
summarize cs_72_1_recoded

*-------------------------------------------------------------------------------
* ANIMAL NAMING (cs_40): imputation for missing values
* Regress cs_40 on i_f_csid_9 and i_f_csid_10, predict if missing
*-------------------------------------------------------------------------------

gen cs_40_recoded = cs_40

* Clean bad values
replace cs_40_recoded = . if cs_40_recoded == 777
replace cs_40_recoded = . if cs_40_recoded > 45

display _newline(1)
display "--- cs_40 (original) ---"
tab cs_40, miss
display "--- cs_40_recoded (after cleaning, before imputation) ---"
summarize cs_40_recoded

* Imputation model
display _newline(1)
display "Animals imputation model:"
xi: reg cs_40_recoded i.i_f_csid_9 i.i_f_csid_10
predict cs_40_pred
quietly count if missing(cs_40_recoded) & !missing(cs_40_pred)
local n_animals_imputed = r(N)
replace cs_40_recoded = cs_40_pred if missing(cs_40_recoded)
display "  Animals imputation filled: `n_animals_imputed' obs"
drop cs_40_pred

display "--- cs_40_recoded (after imputation) ---"
summarize cs_40_recoded

*-------------------------------------------------------------------------------
* PENTAGON DRAWING (cs_32): imputation for missing values
* Regress cs_32 on cs_72_1 cs_72_2 cs_72_3 cs_72_4, predict if missing
*-------------------------------------------------------------------------------

gen cs_32_recoded = cs_32

* Clean bad values
replace cs_32_recoded = . if cs_32_recoded == 11

display _newline(1)
display "--- cs_32 (original) ---"
tab cs_32, miss
display "--- cs_32_recoded (after cleaning, before imputation) ---"
summarize cs_32_recoded

* Imputation model
display _newline(1)
display "Pentagon imputation model:"
xi: reg cs_32_recoded cs_72_1 cs_72_2 cs_72_3 cs_72_4
predict cs_32_pred
quietly count if missing(cs_32_recoded) & !missing(cs_32_pred)
local n_pentagon_imputed = r(N)
replace cs_32_recoded = cs_32_pred if missing(cs_32_recoded)
display "  Pentagon imputation filled: `n_pentagon_imputed' obs"
drop cs_32_pred

* Fallback imputation: use CSID 15 and 16 for remaining missing
quietly count if missing(cs_32_recoded)
local n_still_missing = r(N)
if `n_still_missing' > 0 {
    display _newline(1)
    display "Pentagon imputation model (fallback - CSID 15 & 16):"
    xi: reg cs_32 i.i_f_csid_15 i.i_f_csid_16
    predict cs_32_pred2
    quietly count if missing(cs_32_recoded) & !missing(cs_32_pred2)
    local n_imputed_fallback = r(N)
    replace cs_32_recoded = cs_32_pred2 if missing(cs_32_recoded)
    display "  Fallback imputation filled: `n_imputed_fallback' obs"
    drop cs_32_pred2
}

display "--- cs_32_recoded (after imputation) ---"
summarize cs_32_recoded
