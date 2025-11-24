clear all 
set more off
capture log close
cls

/*
The goal of this do file is to reproduce the 10/66 algorithm using data that's available in the cadas dataset only.
Here's a quick summary of what's in 10/66 but not in cadas
1. cadas has all the variables necessary for completing the cogscore except overlapping circles
2. cadas has all the variables necessary for completing the relscore
3. we might be able to construct some of the whodas12 from the sociodem
4. the Geriatric Mental State (GMS) diagnosis might be able to be created from the sociodem
	link to how to create it can be found here: 
	https://kclpure.kcl.ac.uk/portal/en/publications/the-geriatric-mental-state-examination-in-the-21st-century
	http://www.liv.ac.uk/gms
	https://www-cambridge-org.libproxy.berkeley.edu/core/services/aop-cambridge-core/content/view/8E31B25F1198063EB2229C366FF666B9/S0033291700057779a.pdf/a-computerized-psychiatric-diagnostic-system-and-case-nomenclature-for-elderly-subjects-gms-and-agecat.pdf

conclusion: for now, we will just use continous full versions of the cogscore and relscore
*/

*******ADJUST LOCALS HERE**********

***********************************
local user "Chris"  // Change this to "Will" to switch paths

local Chris "/Users/chrissoria/Documents/Research/CADAS_1066/1066"
local Will "PATH"

local path = cond("`user'" == "Chris", "`Chris'", "`Will'")

cd "`path'"

local wave 1

local drop_missing_from_relscore "no"
local drop_missing_from_cogscore "yes"


***** SCRIPT STARTS HERE *********

**********************************

if `wave' == 1 {
    use "`path'/data/1066_Baseline_data.dta"
}
else if `wave' == 2 {
    use "`path'/data/1066_full_follow_up_Caribbean.dta"
}

if `wave' == 2 {
    foreach var of varlist _all {
        local lowvar = lower("`var'")
        rename `var' `lowvar'
        local newname = substr("`lowvar'", 3, .)
        rename `lowvar' `newname'
    }
gen pid = (ntreid*1000000) + (useid*100) + rticid
*I'm dropping these because they look to have been dropped in the data possible incomplete
drop if inlist(pid, 20028102,20041200,20076700,20129300,20131602)
*I'm dropping this case but I cannot see a reason why it would've been dropped (no missing in relscore)
*I'm assuming it was dropped for a specific resons (singled out)
drop if inlist(pid, 20125302)
*the cogscores below have been dropped for a reason that's not identifiable
*the cdem1066 algo ends up dropping them somewhere in its computation
drop if inlist(pid, 1109201, 1300101, 1300901, 1312101, 1316301, 1316302, 1620901, 2026501, 2040901, 2046001, 2046002, 2066101, 2070001, 2070302, 2583601)
}
else if `wave' == 1 {
    foreach var of varlist _all {
    rename `var' `=lower("`var'")'
}
gen pid = (countryid*1000000) + (region*100000) + (houseid*100) + particid
}

if `wave' == 1 {
    log using 1066_algo_w1.log, text replace
}
else if `wave' == 2 {
    log using 1066_algo_w2.log, text replace
}

*************COGSCORE******************


**************************************

/*

12/26 variables in the 1066 cannot be included in the ADAMS algo
they are: chair shoes knuckle elbow should bridge hammer pray chemist store longmem nod point 
all 0 / 1

*/
gen nametot_duplicate = 0

replace nametot_duplicate = 1 if name > 0 & !missing(name)
replace nametot_duplicate = 1 if nrecall > 0 & !missing(nrecall)

egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point pentag)

* Recoding values from na to 0 so that we can perform the arithmetic

foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point pentag nametot nrecall {
    replace `var' = 0 if `var' == .
}

* Replace 99 with 0 for specific columns
foreach var in animals wordimm worddel paper story {
    replace `var' = 0 if `var' == 99
}

* Replace 9 with 0 for specific columns
foreach var in wordimm worddel paper story {
    replace `var' = 0 if `var' == 9
}
*other variables that we won't be able to use are learn1 learn2 learn3 recall immed nrecall

foreach var in name pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point pentag {
    replace `var' = . if `var' >= 2 & `var' <= 9
}

* more cleaning, recoding any values higher than a certain amount as "na"

local vars "animals wordimm worddel paper story recall immed nrecall"
local nums "45 3 3 3 6 10 29 1"

local n : word count `vars'

forval i = 1/`n' {
    local var : word `i' of `vars'
    local num : word `i' of `nums'
    replace `var' = . if `var' > `num'
}

*dividing by total amount of possible correct answers to get a "total"

local divide_var "animals wordimm worddel paper story"
local divisor "23 3 3 3 6"
local new_column "animtot wordtot1 wordtot2 papertot storytot"

local n : word count `divide_var'

forval i = 1/`n' {
    local col : word `i' of `divide_var'
    local num : word `i' of `divisor'
    local new : word `i' of `new_column'
    
    capture gen `new' = `col'/`num'
    
    if _rc capture replace `new' = `col'/`num'
}


*if we are to weight count for the variables it doesn't have
gen cogscore_cadas = (count + animtot + wordtot1 + wordtot2 + papertot + storytot)

summarize cogscore_cadas 

******************
* RELSCORE
******************

* Creating binary missing indicators without changing the original missing values
local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"

* Creating new binary variables for each original variable to indicate whether the value is missing
foreach var of local miss1_variables {
    gen missing_`var' = missing(`var')
}

* Generating the miss1 variable by summing up the binary missing indicators
egen miss1_cadas = rowtotal(missing_mental missing_activ missing_memory /* 
    */ missing_put missing_kept missing_frdname missing_famname /* 
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* 
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* 
    */ missing_lostin missing_chores missing_hobby missing_money /* 
    */ missing_change missing_reason)

sum memory put frdname famname wordfind wordwrg lastday orient lostout lostin chores money reason feed dress toilet hobby

replace miss1_cadas = miss1_cadas + 1 if inlist(pid, 2108501, 20122802, 20164200)
replace miss1_cadas = 0 if miss1_cadas == .

gen miss3_cadas = 0

local miss3_variables "feed dress toilet"
foreach var of local miss3_variables {
    * Sum up the variables that are missing
    replace miss3_cadas = miss3_cadas + missing(`var')
}

replace miss3_cadas = . if miss3_cadas + miss1_cadas == 24 & miss3 == . 

local all_miss "feed dress toilet"

foreach var of local all_miss {
    gen missing_`var' = missing(`var')
}

* Generating the miss1 variable by summing up the binary missing indicators
egen all_miss = rowtotal(missing_mental missing_activ missing_memory /* 
    */ missing_put missing_kept missing_frdname missing_famname /* 
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* 
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* 
    */ missing_lostin missing_chores missing_hobby missing_money /* 
    */ missing_change missing_reason missing_feed missing_dress missing_toilet)
    
replace miss1_cadas = . if (all_miss ==24 & miss3 == .)

gen misstot_cadas = (miss3_cadas * 3) + miss1_cadas

summarize miss1 miss1_cadas
summarize miss3 miss3_cadas

foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money {
    replace `var'= `var'/2
}

* Backup original 'dress' variable and recode if 'dressdis' is 1
replace dress = 0 if dressdis == 1

* Backup original 'chores' variable and recode if 'choredis' is 1 (I cannot find this)
replace chores = 0 if choredis == 1

* Backup original 'feed' variable and recode if 'feeddis' is 1
replace feed = 0 if feeddis == 1

* Backup original 'toilet' variable and recode if 'toildis' is 1
replace toilet = 0 if toildis == 1

if "`drop_missing_from_relscore'" == "yes" {
    drop if misstot_duplicate > 0
}
		    
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
 
gen T = cond(missing(miss1_cadas), 0, miss1_cadas) + ///
        cond(missing(miss3_cadas), 0, miss3_cadas)

gen relscore_cadas = 30/(30-misstot_cadas)*S

summarize relscore relscore_cadas

******MAIN COMPUTATION*****

****************************

log close
log using "/Users/chrissoria/Documents/Research/1066/cadas_1066_comparison.log", text replace

* ADAMS MODIFIED VERSION
local num_repeats 10

forvalues r = 1/`num_repeats' {
    set seed `r'010
    
    gen ranum = uniform()
    sort ranum
    drop ranum
    
    gen fold_`r' = mod(_n, 10) + 1
    
    gen k_fold_dem_pred_1066_`r' = .
    
    forvalues i = 1/10 {  
        local train = "fold_`r' != `i'" 
        local test = "fold_`r' == `i'"  
        
        quietly logit cdem1066 cogscore_cadas relscore_cadas recall if `train'
        quietly predict p_`r'_`i' if `test', pr
        
        quietly replace k_fold_dem_pred_1066_`r' = p_`r'_`i' if `test'
    }
}

gen total_pred = k_fold_dem_pred_1066_1 + k_fold_dem_pred_1066_2 + k_fold_dem_pred_1066_3 + k_fold_dem_pred_1066_4 + k_fold_dem_pred_1066_5 + k_fold_dem_pred_1066_6 + k_fold_dem_pred_1066_7 + k_fold_dem_pred_1066_8 + k_fold_dem_pred_1066_9 + k_fold_dem_pred_1066_10

gen k_fold_dem_pred_1066_av = total_pred/10

gen cdem1066pred50 = (k_fold_dem_pred_1066_av >= .5) if !missing(k_fold_dem_pred_1066_av)
tab cdem1066pred50
tab cdem1066 cdem1066pred50, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100

display "Sensitivity for 1066 .50: " Sensitivity
display "Specificity for 1066 .50: " Specificity
display "Accuracy for 1066 .50: " Accuracy
display "Predicted Prevalence for 1066 ADAMS modified: " Prevalence
display "Predicted Prevalence for 1066 original: " ((TP+FN) / (TP + TN + FP + FN))*100

roctab cdem1066 cdem1066pred50

* CADAS VERSION
logit cdem1066 cogscore_cadas relscore_cadas recall // coefficients coming from here
predict cdem1066_prob, pr
summarize cdem1066_prob

gen cdem1066_cadas = (cdem1066_prob >= .5) if !missing(cdem1066_prob)
tab cdem1066 cdem1066_cadas
roctab cdem1066 cdem1066_cadas

* CADAS VERSION WITH QUINTILES
*using quintiles from cadas
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

gen bcogscor_quint = .
replace bcogscor_quint = 2.801  if ncogscore_cadas == 1
replace bcogscor_quint = 1.377  if ncogscore_cadas == 2
replace bcogscor_quint = 0.866  if ncogscore_cadas == 3
replace bcogscor_quint = -0.231 if ncogscore_cadas == 4
replace bcogscor_quint = 0      if ncogscore_cadas == 5 & ncogscore_cadas != .

gen brelscor_quint = .
replace brelscor_quint = 0     if nrelscore_cadas == 1
replace brelscor_quint = 1.908 if nrelscore_cadas == 2
replace brelscor_quint = 2.311 if nrelscore_cadas == 3
replace brelscor_quint = 4.171 if nrelscore_cadas == 4
replace brelscor_quint = 5.680 if nrelscore_cadas == 5 & nrelscore_cadas != .

gen bdelay_quint = .
replace bdelay_quint = 3.822 if ndelay_cadas == 1
replace bdelay_quint = 3.349 if ndelay_cadas == 2
replace bdelay_quint = 2.575 if ndelay_cadas == 3
replace bdelay_quint = 2.176 if ndelay_cadas == 4
replace bdelay_quint = 0     if ndelay_cadas == 5 & ndelay_cadas != .

logit cdem1066 bcogscor_quint brelscor_quint bdelay_quint
predict cdem1066_quint_prob, pr

gen cdem1066_quint = (cdem1066_quint_prob >= .5) if !missing(cdem1066_quint_prob)
tab cdem1066 cdem1066_quint
roctab cdem1066 cdem1066_quint

log close


*exit, clear
