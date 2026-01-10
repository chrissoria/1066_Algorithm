********************************************************************************
* GENERATING COEFFICIENTS FROM 10/66 BASELINE DATA
*
* Purpose: Extract logistic regression coefficients from the original 10/66
*          training data for use in CADAS dementia classification
*
* Output: Coefficients for the model: logit cdem1066 cogscore relscore recall
*         - Intercept: 8.486511
*         - cogscore:  -0.4001659
*         - relscore:   0.5024221
*         - recall:    -0.6997248
********************************************************************************

clear all
set more off
capture log close

*-------------------------------------------------------------------------------
* USER CONFIGURATION
*-------------------------------------------------------------------------------

local user "Chris"  // Change this to "Will" to switch paths

local Chris "/Users/chrissoria/Documents/Research/CADAS_1066/1066"
local Will "PATH"

local path = cond("`user'" == "Chris", "`Chris'", "`Will'")

cd "`path'"

local wave 1

local drop_missing_from_relscore "no" // change to yes or no

local topcode_relscore "no"           // change to "yes" to cap relscore at topcode_value
local drop_high_relscore "no"         // change to "yes" to drop cases with relscore > topcode_value
local topcode_value = 20              // maximum relscore value when top-coding or dropping

*-------------------------------------------------------------------------------
* DATA LOADING
*-------------------------------------------------------------------------------

if `wave' == 1 {
    use "`path'/data/1066_Baseline_data.dta"
}
else if `wave' == 2 {
    use "`path'/data/1066_full_follow_up_Caribbean.dta"
}

* Wave 2: Rename variables and create PID
if `wave' == 2 {
    foreach var of varlist _all {
        local lowvar = lower("`var'")
        rename `var' `lowvar'
        local newname = substr("`lowvar'", 3, .)
        rename `lowvar' `newname'
    }
    gen pid = (ntreid*1000000) + (useid*100) + rticid

    * Drop incomplete/problematic cases
    drop if inlist(pid, 20028102,20041200,20076700,20129300,20131602)
    drop if inlist(pid, 20125302)
    drop if inlist(pid, 1109201, 1300101, 1300901, 1312101, 1316301, 1316302, 1620901, 2026501, 2040901, 2046001, 2046002, 2066101, 2070001, 2070302, 2583601)
}

* Wave 1: Lowercase variables and create PID
else if `wave' == 1 {
    foreach var of varlist _all {
        rename `var' `=lower("`var'")'
    }
    gen pid = (countryid*1000000) + (region*100000) + (houseid*100) + particid
}

*-------------------------------------------------------------------------------
* LOG FILE SETUP
*-------------------------------------------------------------------------------

if `wave' == 1 {
    log using 1066_algo_w1.log, text replace
}
else if `wave' == 2 {
    log using 1066_algo_w2.log, text replace
}

*-------------------------------------------------------------------------------
* WHODAS-12 CALCULATION
* Recode and sum WHODAS items, rescale from 36 to 100
*-------------------------------------------------------------------------------

recode pdas2 (1 2 =1) (3 4 =2), gen(pdas2a)
recode pdas4 (1 2 =1) (3 4 =2), gen(pdas4a)
recode pdas8 (1 2 =1) (3 4 =2), gen(pdas8a)
recode pdas10 (1 2 =1) (3 4 =2), gen(pdas10a)
recode pdas11 (1 2 =1) (3 4 =2), gen(pdas11a)
recode pdas12 (1 2 =1) (3 4 =2), gen(pdas12a)

gen whodas12_duplicate=(pdas1+pdas2a+pdas3+pdas4a+pdas5+pdas6+pdas7+pdas8a+pdas9+pdas10a+pdas11a+pdas12a)*(100/36)
summarize whodas12 whodas12_duplicate

replace whodas12 = whodas12_duplicate
drop whodas12_duplicate

*-------------------------------------------------------------------------------
* NAME RECALL (NAMETOT)
* Binary indicator: can recall interviewer's name
*-------------------------------------------------------------------------------

gen nametot_duplicate = 0
replace nametot_duplicate = 1 if name > 0 & !missing(name)
replace nametot_duplicate = 1 if nrecall > 0 & !missing(nrecall)

*-------------------------------------------------------------------------------
* COUNT VARIABLE
* Sum of 26 binary cognitive items
*-------------------------------------------------------------------------------

egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)

*-------------------------------------------------------------------------------
* MISSING VALUE RECODING
* Recode missing values to 0 for arithmetic operations
*-------------------------------------------------------------------------------

foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall {
    replace `var' = 0 if `var' == .
}

* Recode 99s and 9s to 0 (missing/refused codes)
foreach var in animals wordimm worddel paper story {
    replace `var' = 0 if `var' == 99
}

foreach var in wordimm worddel paper story {
    replace `var' = 0 if `var' == 9
}

*-------------------------------------------------------------------------------
* LEARNING TRIALS CLEANING
* Fix data entry errors where values like 11, 20, 21, etc. were entered
* These likely represent single digits (1, 2, 2, etc.)
*-------------------------------------------------------------------------------

foreach var in learn1 learn2 learn3 recall {
    replace `var' = 1 if `var' == 11
    replace `var' = 2 if inlist(`var', 20, 21)
    replace `var' = 3 if inlist(`var', 30, 31)
    replace `var' = 4 if inlist(`var', 40, 41)
    replace `var' = 5 if inlist(`var', 50, 51)
    replace `var' = 6 if inlist(`var', 60, 61)
    replace `var' = 7 if inlist(`var', 70, 71)
    replace `var' = 8 if inlist(`var', 80, 81)
    replace `var' = 9 if inlist(`var', 90, 91)
    replace `var' = . if `var' == 99
}

*-------------------------------------------------------------------------------
* BINARY VARIABLE CLEANING
* Recode values 2-9 as missing for binary items
*-------------------------------------------------------------------------------

foreach var in name pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag {
    replace `var' = . if `var' >= 2 & `var' <= 9
}

*-------------------------------------------------------------------------------
* IMMEDIATE RECALL TOTAL
* Sum of learning trials 1-3
*-------------------------------------------------------------------------------

gen immed_duplicate = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)
summarize immed immed_duplicate

*-------------------------------------------------------------------------------
* OUT-OF-RANGE VALUE CLEANING
* Set values exceeding maximum possible to missing
*-------------------------------------------------------------------------------

local vars "animals wordimm worddel paper story recall immed nrecall"
local nums "45 3 3 3 6 10 29 1"

local n : word count `vars'

forval i = 1/`n' {
    local var : word `i' of `vars'
    local num : word `i' of `nums'
    replace `var' = . if `var' > `num'
}

*-------------------------------------------------------------------------------
* NORMALIZED COMPONENT SCORES
* Divide each component by its maximum possible score
*-------------------------------------------------------------------------------

local divide_var "animals wordimm worddel paper story"
local divisor "23 3 3 3 6"
local new_column "animtot wordtot1 wordtot2 papertot storytot"

local n : word count `divide_var'

forvalues i = 1/`n' {
    local col : word `i' of `divide_var'
    local num : word `i' of `divisor'
    local new : word `i' of `new_column'

    capture gen `new' = `col'/`num'

    if _rc capture replace `new' = `col'/`num'
}

*-------------------------------------------------------------------------------
* COGSCORE CALCULATION
* Formula: 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)
*
* Components:
*   nametot  = ability to say/remember interviewer's name
*   count    = object identification, repetition, orientation, motor skills (26 items)
*   animtot  = animal naming fluency
*   wordtot1 = immediate word recall
*   wordtot2 = delayed word recall
*   papertot = paper folding task
*   storytot = story recall
*-------------------------------------------------------------------------------

capture gen cogscore_duplicate = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)

if `wave' == 1 {
    format cogscore_duplicate %21.8f
}
else if `wave' == 2 {
    format cogscore_duplicate %9.4f
    replace cogscore_duplicate = round(cogscore_duplicate, 0.0001)
    replace cogscore = round(cogscore, 0.0001)
}

summarize cogscore cogscore_duplicate

*-------------------------------------------------------------------------------
* RELSCORE MISSING INDICATORS (MISS1)
* Count missing values for 21 cognitive/behavioral informant items
*-------------------------------------------------------------------------------

local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"

foreach var of local miss1_variables {
    gen missing_`var' = missing(`var')
}

egen miss1_duplicate = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason)

if `wave' == 1 {
    replace miss1_duplicate = 0 if miss1_duplicate == .
}

* Wave 1 specific adjustments for known cases
if `wave' == 1 & "`drop_missing_from_relscore'" != "yes" {
    replace miss1_duplicate = miss1_duplicate + 1 if inlist(pid, 2108501, 20122802, 20164200)
}

*-------------------------------------------------------------------------------
* RELSCORE MISSING INDICATORS (MISS3)
* Count missing values for 3 ADL items (weighted 3x in misstot)
*-------------------------------------------------------------------------------

local miss3_variables "feed dress toilet"

gen miss3_duplicate = 0

foreach var of local miss3_variables {
    replace miss3_duplicate = miss3_duplicate + missing(`var')
}

if `wave' == 1 {
    replace miss3_duplicate = . if miss3_duplicate + miss1_duplicate == 24 & miss3 == .
}

local all_miss "feed dress toilet"

foreach var of local all_miss {
    gen missing_`var' = missing(`var')
}

egen all_miss = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason missing_feed missing_dress missing_toilet)

replace miss1_duplicate = . if (all_miss == 24 & miss3 == .)

*-------------------------------------------------------------------------------
* MISSTOT CALCULATION
* Total missing score: ADL items weighted 3x
* Formula: misstot = (miss3 * 3) + miss1
*-------------------------------------------------------------------------------

gen misstot_duplicate = (miss3_duplicate * 3) + miss1_duplicate

summarize misstot misstot_duplicate
summarize miss1 miss1_duplicate
summarize miss3 miss3_duplicate

*-------------------------------------------------------------------------------
* RELSCORE ITEM RESCALING
* Divide by 2 for items scored 0-2 (to normalize to 0-1 scale)
* Note: reason is NOT divided by 2 (already binary)
*-------------------------------------------------------------------------------

foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money {
    replace `var'= `var'/2
}

if `wave' == 2 {
    replace chores = chores_original
}

*-------------------------------------------------------------------------------
* DISABILITY RECODING FOR RELSCORE
* If disability indicator is present, recode functional item to 0
*-------------------------------------------------------------------------------

replace dress = 0 if dressdis == 1
replace chores = 0 if choredis == 1
replace feed = 0 if feeddis == 1
replace toilet = 0 if toildis == 1

*-------------------------------------------------------------------------------
* DROP CASES WITH MISSING RELSCORE (OPTIONAL)
*-------------------------------------------------------------------------------

if "`drop_missing_from_relscore'" == "yes" {
    drop if misstot_duplicate > 0
}

*-------------------------------------------------------------------------------
* RELSCORE CALCULATION
* S = sum of 24 informant items (missing treated as 0)
* U = weighting factor for missing items: 30 / (30 - misstot)
* relscore = U * S
*-------------------------------------------------------------------------------

gen S = cond(missing(activ), 0, activ) +  ///
        cond(missing(mental), 0, mental) + ///
        cond(missing(memory), 0, memory) + ///
        cond(missing(put), 0, put) + ///
        cond(missing(kept), 0, kept) + ///
        cond(missing(frdname), 0, frdname) + ///
        cond(missing(famname), 0, famname) + ///
        cond(missing(convers), 0, convers) + ///
        cond(missing(wordfind), 0, wordfind) + ///
        cond(missing(wordwrg), 0, wordwrg) + ///
        cond(missing(past), 0, past) + ///
        cond(missing(lastsee), 0, lastsee) + ///
        cond(missing(lastday), 0, lastday) + ///
        cond(missing(orient), 0, orient) + ///
        cond(missing(lostout), 0, lostout) + ///
        cond(missing(lostin), 0, lostin) + ///
        cond(missing(chores), 0, chores) + ///
        cond(missing(hobby), 0, hobby) + ///
        cond(missing(money), 0, money) + ///
        cond(missing(change), 0, change) + ///
        cond(missing(reason), 0, reason) + ///
        cond(missing(feed), 0, feed) + ///
        cond(missing(dress), 0, dress) + ///
        cond(missing(toilet), 0, toilet)

gen T = cond(missing(miss1_duplicate), 0, miss1_duplicate) + ///
        cond(missing(miss3_duplicate), 0, miss3_duplicate)

gen U = 30 / (30 - misstot)
replace U = cond(missing(misstot), 0, U)
replace U = . if misstot >= 30  // Handle division by zero

gen relscore_duplicate = U * S

*-------------------------------------------------------------------------------
* QUALITY CHECK: SET RELSCORE TO MISSING IF >50% OF ITEMS ARE MISSING
* 24 total items (21 in miss1 + 3 in miss3), so >12 missing = unreliable
* This matches the quality check applied in CADAS
*-------------------------------------------------------------------------------

gen relscore_items_missing = miss1_duplicate + miss3_duplicate
replace relscore_duplicate = . if relscore_items_missing > 12

quietly count if relscore_items_missing > 12
display "Cases with >50% relscore items missing (set to .): " r(N)

summarize relscore_duplicate relscore_original

*-------------------------------------------------------------------------------
* PREDICTED RELSCORE (FOR MISSING IMPUTATION)
* Uses WHODAS and NPI severity to predict relscore when missing
*-------------------------------------------------------------------------------

gen pred_relscore = 0.004 + (0.072 * whodas12) + (0.338 * npisev)

replace pred_relscore = 0 if pred_relscore <= 0
replace pred_relscore = 30 if pred_relscore >= 30 & !missing(pred_relscore)

* Impute missing relscore with predicted values
replace relscore_duplicate = pred_relscore if relscore_duplicate == . & pred_relscore != .

summarize relscore_duplicate relscore

*-------------------------------------------------------------------------------
* DFSCORE CALCULATION (DISCRIMINANT FUNCTION SCORE)
* Original 10/66 algorithm intermediate score
*-------------------------------------------------------------------------------

generate dfscore_duplicate = 0.452322 - (0.01669918 * cogscore_duplicate) + (0.03033851 * relscore_duplicate)

summarize dfscore dfscore_duplicate

*-------------------------------------------------------------------------------
* DFCASE CATEGORIES
* Categorize discriminant function score
*-------------------------------------------------------------------------------

gen dfcase_duplicate = .
replace dfcase_duplicate = 1 if dfscore_duplicate <= 0.119999999
replace dfcase_duplicate = 2 if dfscore_duplicate >= 0.12 & dfscore_duplicate < 0.184
replace dfcase_duplicate = 3 if dfscore_duplicate >= 0.184 & dfscore_duplicate < .

summarize dfcase_duplicate dfcase

*-------------------------------------------------------------------------------
* COGCASE CATEGORIES
* Categorize cognitive score
*-------------------------------------------------------------------------------

gen cogcase_duplicate = .
replace cogcase_duplicate = 3 if cogscore <= 28.5
replace cogcase_duplicate = 2 if cogscore > 28.5 & cogscore <= 29.5
replace cogcase_duplicate = 1 if cogscore > 29.5 & cogscore != .

summarize cogcase_duplicate cogcase

*-------------------------------------------------------------------------------
* QUINTILE CATEGORIES (ORIGINAL 10/66 CUTPOINTS)
* ncogscor, nrelscor, ndelay: 1-5 categories for algorithm
*-------------------------------------------------------------------------------

gen ncogscor_duplicate = .
replace ncogscor_duplicate = 1 if cogscore <= 23.699
replace ncogscor_duplicate = 2 if cogscore > 23.699 & cogscore <= 28.619
replace ncogscor_duplicate = 3 if cogscore > 28.619 & cogscore <= 30.619
replace ncogscor_duplicate = 4 if cogscore > 30.619 & cogscore <= 31.839
replace ncogscor_duplicate = 5 if cogscore > 31.839 & cogscore != .

gen nrelscor_duplicate = .
replace nrelscor_duplicate = 1 if relscore_duplicate == 0
replace nrelscor_duplicate = 2 if relscore_duplicate > 0 & relscore_duplicate <= 1.99
replace nrelscor_duplicate = 3 if relscore_duplicate > 1.99 & relscore_duplicate <= 5.0
replace nrelscor_duplicate = 4 if relscore_duplicate > 5.0 & relscore_duplicate <= 12.0
replace nrelscor_duplicate = 5 if relscore_duplicate > 12.0 & relscore_duplicate != .

gen ndelay_duplicate = .
replace ndelay_duplicate = 1 if recall == 0
replace ndelay_duplicate = 2 if recall >= 1 & recall <= 3
replace ndelay_duplicate = 3 if recall == 4
replace ndelay_duplicate = 4 if recall >= 5 & recall <= 6
replace ndelay_duplicate = 5 if recall >= 7 & recall != .

*-------------------------------------------------------------------------------
* BETA COEFFICIENTS FOR QUINTILE CATEGORIES
* Convert quintile categories to weighted scores for classification
*-------------------------------------------------------------------------------

gen brelscor_duplicate = .
replace brelscor_duplicate = 0     if nrelscor_duplicate == 1
replace brelscor_duplicate = 1.908 if nrelscor_duplicate == 2
replace brelscor_duplicate = 2.311 if nrelscor_duplicate == 3
replace brelscor_duplicate = 4.171 if nrelscor_duplicate == 4
replace brelscor_duplicate = 5.680 if nrelscor_duplicate == 5 & nrelscor_duplicate != .

gen bcogscor_duplicate = .
replace bcogscor_duplicate = 2.801  if ncogscor_duplicate == 1
replace bcogscor_duplicate = 1.377  if ncogscor_duplicate == 2
replace bcogscor_duplicate = 0.866  if ncogscor_duplicate == 3
replace bcogscor_duplicate = -0.231 if ncogscor_duplicate == 4
replace bcogscor_duplicate = 0      if ncogscor_duplicate == 5 & ncogscor_duplicate != .

gen bdelay_duplicate = .
replace bdelay_duplicate = 3.822 if ndelay_duplicate == 1
replace bdelay_duplicate = 3.349 if ndelay_duplicate == 2
replace bdelay_duplicate = 2.575 if ndelay_duplicate == 3
replace bdelay_duplicate = 2.176 if ndelay_duplicate == 4
replace bdelay_duplicate = 0     if ndelay_duplicate == 5 & ndelay_duplicate != .

gen bgmsdiag_duplicate = .
replace bgmsdiag_duplicate = 0      if gmsdiag == 6
replace bgmsdiag_duplicate = 1.566  if gmsdiag == 1
replace bgmsdiag_duplicate = 1.545  if gmsdiag == 2
replace bgmsdiag_duplicate = -0.635 if gmsdiag == 3
replace bgmsdiag_duplicate = -0.674 if gmsdiag == 4
replace bgmsdiag_duplicate = 0.34   if gmsdiag == 5 & gmsdiag != .

*-------------------------------------------------------------------------------
* DATA-DRIVEN QUINTILES
* Create quintile categories from actual data distribution
*-------------------------------------------------------------------------------

xtile ncogscor_quint = cogscore, nq(5)
xtile nrelscor_quint = relscore_duplicate, nq(5)
xtile ndelay_quint = recall, nq(5)

*-------------------------------------------------------------------------------
* CADAS QUINTILE CUTPOINTS
* Quintile categories using CADAS-derived cutpoints
*-------------------------------------------------------------------------------

gen ncogscore_cadas = .
replace ncogscore_cadas = 1 if cogscore <= 28.38926696777344
replace ncogscore_cadas = 2 if cogscore > 28.38926696777344 & cogscore <= 29.75679397583008
replace ncogscore_cadas = 3 if cogscore > 29.75679397583008 & cogscore <= 30.57880401611328
replace ncogscore_cadas = 4 if cogscore > 30.57880401611328 & cogscore <= 31.3485050201416
replace ncogscore_cadas = 5 if cogscore > 31.3485050201416 & cogscore != .

gen nrelscore_cadas = .
replace nrelscore_cadas = 1 if relscore <= 0
replace nrelscore_cadas = 2 if relscore > 0 & relscore <= .5
replace nrelscore_cadas = 3 if relscore > .5 & relscore <= 1.5
replace nrelscore_cadas = 4 if relscore > 1.5 & relscore <= 2.5
replace nrelscore_cadas = 5 if relscore > 2.5 & relscore != .

gen ndelay_cadas = .
replace ndelay_cadas = 1 if recall <= 2
replace ndelay_cadas = 2 if recall > 2 & recall <= 3
replace ndelay_cadas = 3 if recall > 3 & recall <= 4
replace ndelay_cadas = 4 if recall > 4 & recall <= 5
replace ndelay_cadas = 5 if recall > 5 & recall != .

*-------------------------------------------------------------------------------
* ORIGINAL 10/66 CLASSIFICATION (WITH GMSDIAG)
* Uses quintile categories and GMS diagnosis
*-------------------------------------------------------------------------------

gen Q = brelscor_duplicate + bcogscor_duplicate + bdelay_duplicate + bgmsdiag_duplicate
gen logodds_duplicate = -9.53 + Q

gen odds_duplicate = exp(logodds_duplicate)

gen prob_duplicate = odds_duplicate / (1 + odds_duplicate)

gen dem1066_duplicate = .
replace dem1066_duplicate = 0 if prob_duplicate <= 0.25591
replace dem1066_duplicate = 1 if prob_duplicate > 0.25591 & prob_duplicate != .

summarize dem1066_duplicate dem1066

tab dem1066_duplicate dem1066, miss

count if dem1066_duplicate == 1
count if cdem1066 == 1

********************************************************************************
* COEFFICIENT EXTRACTION FOR CADAS
* Extract logistic regression coefficients for continuous variable model
* This is the PRIMARY output used in the CADAS 1066 algorithm
********************************************************************************

*-------------------------------------------------------------------------------
* USE CLEANED RELSCORE FOR COEFFICIENT EXTRACTION
* Replace original relscore with quality-checked relscore_duplicate
*-------------------------------------------------------------------------------

drop relscore
rename relscore_duplicate relscore

display "Using cleaned relscore (cases with >50% missing set to .):"
summarize relscore

*-------------------------------------------------------------------------------
* TOP-CODE RELSCORE (OPTIONAL)
* For sensitivity analysis: cap extreme relscore values
*-------------------------------------------------------------------------------

if "`topcode_relscore'" == "yes" {
    display _newline(1)
    display "TOP-CODING RELSCORE: values > `topcode_value' set to `topcode_value'"
    count if relscore > `topcode_value' & !missing(relscore)
    display "  Cases affected: " r(N)
    replace relscore = `topcode_value' if relscore > `topcode_value' & !missing(relscore)
    display "After top-coding:"
    summarize relscore
}

if "`drop_high_relscore'" == "yes" {
    display _newline(1)
    display "DROPPING CASES: relscore > `topcode_value'"
    count if relscore > `topcode_value' & !missing(relscore)
    display "  Cases to drop: " r(N)
    drop if relscore > `topcode_value' & !missing(relscore)
    display "After dropping:"
    summarize relscore
    display "  Remaining N: " _N
}

*-------------------------------------------------------------------------------
* MAIN MODEL: cogscore + relscore + recall
* These coefficients are used in CADAS 1066_step5_classify.do
*-------------------------------------------------------------------------------

logit cdem1066 cogscore relscore recall
predict cdem1066_prob, pr
summarize cdem1066_prob

* Linear regression for comparison
regress cdem1066 cogscore relscore recall

********************************************************************************
* SENSITIVITY ANALYSES / ALTERNATIVE MODELS
********************************************************************************

*-------------------------------------------------------------------------------
* MODEL: Original quintile categories
*-------------------------------------------------------------------------------

logit cdem1066 bcogscor brelscor bdelay
predict dem1066_orig_quints, pr

gen dem1066_orig_quint = (dem1066_orig_quints >= .5) if !missing(dem1066_orig_quints)

tab cdem1066 dem1066_orig_quint
roctab cdem1066 dem1066_orig_quint

*-------------------------------------------------------------------------------
* MODEL: Data-driven quintiles
*-------------------------------------------------------------------------------

logit cdem1066 ncogscor_quint nrelscor_quint ndelay_quint

*-------------------------------------------------------------------------------
* MODEL: Binary relscore (>4 threshold)
*-------------------------------------------------------------------------------

gen rel_binary = (relscore > 4) if relscore != .
logit cdem1066 cogscore rel_binary recall

*-------------------------------------------------------------------------------
* MODEL: CADAS quintile cutpoints
*-------------------------------------------------------------------------------

logit cdem1066 ncogscore_cadas nrelscore_cadas ndelay_cadas
predict dem1066_quint_prob, pr

gen dem1066_quint = (dem1066_quint_prob >= .5) if !missing(dem1066_quint_prob)

tab cdem1066 dem1066_quint
roctab cdem1066 dem1066_quint

*-------------------------------------------------------------------------------
* MODEL: Individual cognitive components
*-------------------------------------------------------------------------------

logit cdem1066 nametot count animtot wordtot1 wordtot2 papertot storytot relscore recall
predict dem1066_cog_comp_prob, pr

gen dem1066_cog_comp = (dem1066_cog_comp_prob >= .5) if !missing(dem1066_cog_comp_prob)

tab cdem1066 dem1066_cog_comp
roctab cdem1066 dem1066_cog_comp

*-------------------------------------------------------------------------------
* MODEL: Cogscore x relscore interaction
*-------------------------------------------------------------------------------

gen cog_rel_interact = cogscore * relscore
logit cdem1066 cogscore relscore recall cog_rel_interact
predict prob_interaction, pr
roctab cdem1066 prob_interaction

*-------------------------------------------------------------------------------
* MODEL: Learn1 instead of recall
*-------------------------------------------------------------------------------

logit cdem1066 cogscore relscore learn1
predict cdem1066_learn1_prob, pr
summarize cdem1066_learn1_prob

gen dem1066_learn1 = (cdem1066_learn1_prob >= .5) if !missing(cdem1066_learn1_prob)

roctab cdem1066 cdem1066_learn1_prob

*-------------------------------------------------------------------------------
* MODEL: Learn3 instead of recall
*-------------------------------------------------------------------------------

logit cdem1066 cogscore relscore learn3
predict cdem1066_learn3_prob, pr
summarize cdem1066_learn3_prob

gen dem1066_learn3 = (cdem1066_learn3_prob >= .5) if !missing(cdem1066_learn3_prob)

roctab cdem1066 cdem1066_learn3_prob

log close

*-------------------------------------------------------------------------------
* EXPORT DIAGNOSTICS
* Save variable statistics to CSV for validation
*-------------------------------------------------------------------------------

preserve

local vars relscore cogscore nametot count animals animtot wordtot1 wordtot2 papertot story storytot pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town street store address month day year nod point pentag chief longmem season wordimm worddel misstot activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet recall cdem1066_prob cdem1066 S learn1 learn3

postfile handle str32 variable mean min max using results_temp.dta, replace
foreach v of local vars {
    quietly summarize `v'
    post handle ("`v'") (r(mean)) (r(min)) (r(max))
}
postclose handle

use results_temp.dta, clear

export delimited using "/Users/chrissoria/Documents/CADAS/Data/Cuba_Out/1066_1066_diagnostics.csv", replace

restore

*-------------------------------------------------------------------------------
* SAVE REFERENCE DATASET FOR CADAS VALIDATION
* This dataset contains all variables needed to compare with CADAS output
*-------------------------------------------------------------------------------

* Drop original variables and rename duplicates to match CADAS variable names
* Note: relscore was already renamed at line 569 (quality-checked version)

drop cogscore
rename cogscore_duplicate cogscore

capture drop miss1
rename miss1_duplicate miss1

capture drop miss3
rename miss3_duplicate miss3

capture drop misstot
rename misstot_duplicate misstot

* Create dem1066_score using the same formula as CADAS
gen dem1066_score = exp(8.486511 - 0.4001659*cogscore + 0.5024221*relscore - 0.6997248*recall) / ///
                    (1 + exp(8.486511 - 0.4001659*cogscore + 0.5024221*relscore - 0.6997248*recall))

gen dem1066_calc = (dem1066_score >= 0.5) if !missing(dem1066_score)

* Keep variables that match CADAS 1066 output
keep pid countryid cogscore age relscore recall dem1066_score dem1066_calc cdem1066 ///
     nametot count animals animtot wordimm worddel wordtot1 wordtot2 ///
     paper papertot story storytot immed learn1 learn2 learn3 ///
     pencil watch chair shoes knuckle elbow should bridge hammer ///
     pray chemist repeat town chief street store address longmem ///
     month day year season nod point circle pentag ///
     activ mental memory put kept frdname famname convers ///
     wordfind wordwrg past lastsee lastday orient lostout lostin ///
     chores hobby money change reason feed dress toilet ///
     miss1 miss3 misstot

* Rename dem1066_calc to dem1066 for comparison
rename dem1066_calc dem1066

* Save reference dataset
save "/Users/chrissoria/Documents/Research/CADAS_1066/1066/1066_reference_for_validation.dta", replace

display "Reference dataset saved to: /Users/chrissoria/Documents/Research/CADAS_1066/1066/1066_reference_for_validation.dta"
