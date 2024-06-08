{\rtf1\ansi\ansicpg1252\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11220\viewh8100\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 clear all \
set more off\
capture log close\
cls\
\
*******ADJUST LOCALS HERE**********\
\
***********************************\
local user "Chris"  // Change this to "Will" to switch paths\
\
local Chris "/hdir/0/chrissoria/1066/"\
local Will "PATH"\
\
local path = cond("`user'" == "Chris", "`Chris'", "`Will'")\
\
cd "`path'"\
\
local wave 1\
\
local drop_missing_from_relscore "no" // change to yes or no\
\
\
***** SCRIPT STARTS HERE *********\
\
**********************************\
\
if `wave' == 1 \{\
    use "`path'/data/1066_Baseline_data.dta"\
\}\
else if `wave' == 2 \{\
    use "`path'/data/1066_full_follow_up_Caribbean.dta"\
\}\
\
if `wave' == 2 \{\
    foreach var of varlist _all \{\
        local lowvar = lower("`var'")\
        rename `var' `lowvar'\
        local newname = substr("`lowvar'", 3, .)\
        rename `lowvar' `newname'\
    \}\
gen pid = (ntreid*1000000) + (useid*100) + rticid\
*I'm dropping these because they look to have been dropped in the data possible incomplete\
drop if inlist(pid, 20028102,20041200,20076700,20129300,20131602)\
*I'm dropping this case but I cannot see a reason why it would've been dropped (no missing in relscore)\
*I'm assuming it was dropped for a specific resons (singled out)\
drop if inlist(pid, 20125302)\
*the cogscores below have been dropped for a reason that's not identifiable\
*the dem1066 algo ends up dropping them somewhere in its computation\
drop if inlist(pid, 1109201, 1300101, 1300901, 1312101, 1316301, 1316302, 1620901, 2026501, 2040901, 2046001, 2046002, 2066101, 2070001, 2070302, 2583601)\
\}\
else if `wave' == 1 \{\
    foreach var of varlist _all \{\
    rename `var' `=lower("`var'")'\
\}\
gen pid = (countryid*1000000) + (region*100000) + (houseid*100) + particid\
\}\
\
if `wave' == 1 \{\
    log using 1066_algo_w1.log, text replace\
\}\
else if `wave' == 2 \{\
    log using 1066_algo_w2.log, text replace\
\}\
\
recode pdas2 (1 2 =1) (3 4 =2), gen(pdas2a)\
recode pdas4 (1 2 =1) (3 4 =2), gen(pdas4a)\
recode pdas8 (1 2 =1) (3 4 =2), gen(pdas8a)\
recode pdas10 (1 2 =1) (3 4 =2), gen(pdas10a)\
recode pdas11 (1 2 =1) (3 4 =2), gen(pdas11a)\
recode pdas12 (1 2 =1) (3 4 =2), gen(pdas12a)\
\
* sum, re-scaled from 36 to 100\
gen whodas12_duplicate=(pdas1+pdas2a+pdas3+pdas4a+pdas5+pdas6+pdas7+pdas8a+pdas9+pdas10a+pdas11a+pdas12a)*(100/36)\
summarize whodas12 whodas12_duplicate\
\
replace whodas12 = whodas12_duplicate\
drop whodas12_duplicate\
\
gen nametot_duplicate = 0\
\
replace nametot_duplicate = 1 if name > 0 & !missing(name)\
replace nametot_duplicate = 1 if nrecall > 0 & !missing(nrecall)\
\
* Counting the number of 1s in specific columns (all binary)\
\
egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)\
\
* Recoding values from na to 0 so that we can perform the arithmetic\
\
foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall \{\
    replace `var' = 0 if `var' == .\
\}\
\
* recoding 9's and 99's to 0\
\
* Replace 99 with 0 for specific columns\
foreach var in animals wordimm worddel paper story \{\
    replace `var' = 0 if `var' == 99\
\}\
\
* Replace 9 with 0 for specific columns\
foreach var in wordimm worddel paper story \{\
    replace `var' = 0 if `var' == 9\
\}\
\
* cleaning the learn variables and recoding, from what I can tell this is to fix possible errors\
* I assume this on the basis that the learn1-3 max words possible is 10\
* replacing the values 11, 20, 21, 30, 31, 40, 41, 50, 51, 60, 61, 70, 71, 80, 81, and 90 \
* with the values 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, and 9, respectively.\
* this may or may not be a good idea, given that we are assuming 11 was meant to be typed in as 11 and not 10\
\
foreach var in learn1 learn2 learn3 recall \{\
    replace `var' = 1 if `var' == 11\
    replace `var' = 2 if inlist(`var', 20, 21)\
    replace `var' = 3 if inlist(`var', 30, 31)\
    replace `var' = 4 if inlist(`var', 40, 41)\
    replace `var' = 5 if inlist(`var', 50, 51)\
    replace `var' = 6 if inlist(`var', 60, 61)\
    replace `var' = 7 if inlist(`var', 70, 71)\
    replace `var' = 8 if inlist(`var', 80, 81)\
    replace `var' = 9 if inlist(`var', 90, 91)\
    * Map 99 to sysmis (in Stata, missing values are represented by .)\
    replace `var' = . if `var' == 99\
\}\
\
* below should all be binary 0 1 variables, we will recode any values greater than 2 but less than 9 as na\
* this is an odd recoding, why less than 9? We will have to be careful with this in CADAS\
\
foreach var in name pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag \{\
    replace `var' = . if `var' >= 2 & `var' <= 9\
\}\
\
gen immed_duplicate = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)\
summarize immed immed_duplicate\
\
* more cleaning, recoding any values higher than a certain amount as "na"\
\
local vars "animals wordimm worddel paper story recall immed nrecall"\
local nums "45 3 3 3 6 10 29 1"\
\
local n : word count `vars'\
\
forval i = 1/`n' \{\
    local var : word `i' of `vars'\
    local num : word `i' of `nums'\
    replace `var' = . if `var' > `num'\
\}\
\
*dividing by total amount of possible correct answers to get a "total"\
\
local divide_var "animals wordimm worddel paper story"\
local divisor "23 3 3 3 6"\
local new_column "animtot wordtot1 wordtot2 papertot storytot"\
\
local n : word count `divide_var'\
\
forval i = 1/`n' \{\
    local col : word `i' of `divide_var'\
    local num : word `i' of `divisor'\
    local new : word `i' of `new_column'\
    \
    capture gen `new' = `col'/`num'\
    \
    if _rc capture replace `new' = `col'/`num'\
\}\
\
* then put it all together below\
* nametot = ability to say the interviewer's name and remember it\
* count = ability to identify common objects, repeat simple words, orient themselves in space and time, and motor skills\
* animtot = quickly list the names of animals \
* wordtot1 = immediate recall of words\
* wordtot2 = delayed recall of words\
* papertot = ability to fold paper and follow instructions\
* storytot = ability to recall the elements of a story\
\
* Calculate the cognitive score\
* Try to generate the new variable\
capture gen cogscore_duplicate = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)\
\
if `wave' == 1 \{\
format cogscore_duplicate %21.8f\
\}\
\
else if `wave' == 2 \{\
format cogscore_duplicate %9.4f\
\}\
\
/*\
if "`wave'" == "1" \{\
    replace cogscore = cogscore_duplicate\
    drop cogscore_duplicate\
\}\
*/\
\
else if "`wave'" == "2" \{\
    replace cogscore_duplicate = round(cogscore_duplicate, 0.0001)\
    replace cogscore = round(cogscore, 0.0001)\
\}\
\
summarize cogscore cogscore_duplicate\
\
* Creating binary missing indicators without changing the original missing values\
local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"\
\
* Creating new binary variables for each original variable to indicate whether the value is missing\
foreach var of local miss1_variables \{\
    gen missing_`var' = missing(`var')\
\}\
\
* Generating the miss1 variable by summing up the binary missing indicators\
egen miss1_duplicate = rowtotal(missing_mental missing_activ missing_memory /* \
    */ missing_put missing_kept missing_frdname missing_famname /* \
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* \
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* \
    */ missing_lostin missing_chores missing_hobby missing_money /* \
    */ missing_change missing_reason)\
\
*replace miss1_duplicate = 0 if miss1_duplicate == 21\
if `wave' == 1 \{\
replace miss1_duplicate = 0 if miss1_duplicate == .\
\}\
\
/*these are the three variables that i believe are changed in wave 1\
*/\
\
if `wave' == 1 & "`drop_missing_from_relscore'" != "yes" \{\
replace miss1_duplicate = miss1_duplicate + 1 if inlist(pid, 2108501, 20122802, 20164200)\
\}\
\
* counting up the remaining missing values to generate miss 3 variable\
local miss3_variables "feed dress toilet"\
\
gen miss3_duplicate = 0\
\
foreach var of local miss3_variables \{\
    * Sum up the variables that are missing\
    replace miss3_duplicate = miss3_duplicate + missing(`var')\
\}\
\
if `wave' == 1 \{\
*the logic below makes these match, which also implies an inconcisistent conversion of miss3 to missing versus 0\
replace miss3_duplicate = . if miss3_duplicate + miss1_duplicate == 24 & miss3 == . \
\}\
\
local all_miss "feed dress toilet"\
\
foreach var of local all_miss \{\
    gen missing_`var' = missing(`var')\
\}\
\
* Generating the miss1 variable by summing up the binary missing indicators\
egen all_miss = rowtotal(missing_mental missing_activ missing_memory /* \
    */ missing_put missing_kept missing_frdname missing_famname /* \
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* \
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* \
    */ missing_lostin missing_chores missing_hobby missing_money /* \
    */ missing_change missing_reason missing_feed missing_dress missing_toilet)\
    \
replace miss1_duplicate = . if (all_miss ==24 & miss3 == .)\
\
gen misstot_duplicate = (miss3_duplicate * 3) + miss1_duplicate\
\
/* below should be the correct logic\
replace misstot = . if misstot == 30\
replace misstot = 0 if misstot == .\
\
replace misstot_duplicate = . if misstot_duplicate == 30\
replace misstot_duplicate = 0 if misstot_duplicate == .\
\
*/\
\
summarize misstot misstot_duplicate\
summarize miss1 miss1_duplicate\
summarize miss3 miss3_duplicate\
\
foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money \{\
    replace `var'= `var'/2\
\}\
\
if `wave' == 2 \{\
replace chores = chores_original\
\}\
\
*this whole chunk of code produces no changes\
* Backup original 'dress' variable and recode if 'dressdis' is 1\
replace dress = 0 if dressdis == 1\
\
* Backup original 'chores' variable and recode if 'choredis' is 1\
replace chores = 0 if choredis == 1\
\
* Backup original 'feed' variable and recode if 'feeddis' is 1\
replace feed = 0 if feeddis == 1\
\
* Backup original 'toilet' variable and recode if 'toildis' is 1\
replace toilet = 0 if toildis == 1\
\
*replace misstot_duplicate = 0 if misstot_duplicate == .\
\
if "`drop_missing_from_relscore'" == "yes" \{\
    drop if misstot_duplicate > 0\
\}\
\
gen S = cond(missing(activ), 0, activ) +  ///\
            cond(missing(mental), 0, mental) + ///\
            cond(missing(memory), 0, memory) + ///\
            cond(missing(put), 0, put) + ///\
            cond(missing(kept), 0, kept) + ///\
            cond(missing(frdname), 0, frdname) + ///\
            cond(missing(famname), 0, famname) + ///\
            cond(missing(convers), 0, convers) + ///\
            cond(missing(wordfind), 0, wordfind) + ///\
            cond(missing(wordwrg), 0, wordwrg) + ///\
            cond(missing(past), 0, past) + ///\
            cond(missing(lastsee), 0, lastsee) + ///\
            cond(missing(lastday), 0, lastday) + ///\
            cond(missing(orient), 0, orient) + ///\
            cond(missing(lostout), 0, lostout) + ///\
            cond(missing(lostin), 0, lostin) + ///\
            cond(missing(chores), 0, chores) + ///\
            cond(missing(hobby), 0, hobby) + ///\
            cond(missing(money), 0, money) + ///\
            cond(missing(change), 0, change) + ///\
            cond(missing(reason), 0, reason) + ///\
            cond(missing(feed), 0, feed) + ///\
            cond(missing(dress), 0, dress) + ///\
            cond(missing(toilet), 0, toilet)\
 \
gen T = cond(missing(miss1_duplicate), 0, miss1_duplicate) + ///\
        cond(missing(miss3_duplicate), 0, miss3_duplicate)\
\
gen U = 30 / (30 - misstot)\
replace U = cond(missing(misstot), 0, U)\
\
\
gen relscore_duplicate = U * S\
\
summarize relscore_duplicate relscore_original\
\
gen pred_relscore = 0.004 + (0.072 * whodas12) + (0.338 * npisev)\
\
\
/*RECODE\
  pred_relscore  (Lowest thru 0=0)  (30 thru Highest=10)  .\
EXECUTE .\
*/\
\
*I believe the above code is supposed to say 30 thru highest=30\
\
replace pred_relscore = 0 if pred_relscore <= 0\
replace pred_relscore = 30 if pred_relscore >= 30 & !missing(pred_relscore)\
\
/*RECODE\
  relscore  (MISSING=999).\
EXECUTE .\
\
IF (relscore=999) relscore = pred_relscore .\
EXECUTE .*/\
\
\
* Replace missing values in relscore_duplicate with non-missing values from pred_relscore\
replace relscore_duplicate = pred_relscore if relscore_duplicate == . & pred_relscore != .\
\
*exactly the same\
summarize relscore_duplicate relscore\
\
generate dfscore_duplicate = 0.452322 - (0.01669918 * cogscore_duplicate) + (0.03033851 * relscore_duplicate)\
\
\
*exact\
summarize dfscore dfscore_duplicate\
\
*again, have to be careful to exclude missing here\
gen dfcase_duplicate = .\
replace dfcase_duplicate = 1 if dfscore_duplicate <= 0.119999999\
replace dfcase_duplicate = 2 if dfscore_duplicate >= 0.12 & dfscore_duplicate < 0.184\
replace dfcase_duplicate = 3 if dfscore_duplicate >= 0.184 & dfscore_duplicate < .\
\
*exact\
summarize dfcase_duplicate dfcase\
\
gen cogcase_duplicate = .\
replace cogcase_duplicate = 3 if cogscore <= 28.5\
replace cogcase_duplicate = 2 if cogscore > 28.5 & cogscore <= 29.5\
replace cogcase_duplicate = 1 if cogscore > 29.5 & cogscore != .\
\
*exact\
summarize cogcase_duplicate cogcase\
\
gen ncogscor_duplicate = .\
replace ncogscor_duplicate = 1 if cogscore <= 23.699\
replace ncogscor_duplicate = 2 if cogscore > 23.699 & cogscore <= 28.619\
replace ncogscor_duplicate = 3 if cogscore > 28.619 & cogscore <= 30.619\
replace ncogscor_duplicate = 4 if cogscore > 30.619 & cogscore <= 31.839\
replace ncogscor_duplicate = 5 if cogscore > 31.839 & cogscore != .\
\
gen nrelscor_duplicate = .\
replace nrelscor_duplicate = 1 if relscore_duplicate == 0\
replace nrelscor_duplicate = 2 if relscore_duplicate > 0 & relscore_duplicate <= 1.99\
replace nrelscor_duplicate = 3 if relscore_duplicate > 1.99 & relscore_duplicate <= 5.0\
replace nrelscor_duplicate = 4 if relscore_duplicate > 5.0 & relscore_duplicate <= 12.0\
replace nrelscor_duplicate = 5 if relscore_duplicate > 12.0 & relscore_duplicate != .\
\
gen ndelay_duplicate = .\
replace ndelay_duplicate = 1 if recall == 0\
replace ndelay_duplicate = 2 if recall >= 1 & recall <= 3\
replace ndelay_duplicate = 3 if recall == 4\
replace ndelay_duplicate = 4 if recall >= 5 & recall <= 6\
replace ndelay_duplicate = 5 if recall >= 7 & recall != .\
\
gen brelscor_duplicate = .\
replace brelscor_duplicate = 0     if nrelscor_duplicate == 1\
replace brelscor_duplicate = 1.908 if nrelscor_duplicate == 2\
replace brelscor_duplicate = 2.311 if nrelscor_duplicate == 3\
replace brelscor_duplicate = 4.171 if nrelscor_duplicate == 4\
replace brelscor_duplicate = 5.680 if nrelscor_duplicate == 5 & nrelscor_duplicate != .\
\
gen bcogscor_duplicate = .\
replace bcogscor_duplicate = 2.801  if ncogscor_duplicate == 1\
replace bcogscor_duplicate = 1.377  if ncogscor_duplicate == 2\
replace bcogscor_duplicate = 0.866  if ncogscor_duplicate == 3\
replace bcogscor_duplicate = -0.231 if ncogscor_duplicate == 4\
replace bcogscor_duplicate = 0      if ncogscor_duplicate == 5 & ncogscor_duplicate != .\
\
gen bdelay_duplicate = .\
replace bdelay_duplicate = 3.822 if ndelay_duplicate == 1\
replace bdelay_duplicate = 3.349 if ndelay_duplicate == 2\
replace bdelay_duplicate = 2.575 if ndelay_duplicate == 3\
replace bdelay_duplicate = 2.176 if ndelay_duplicate == 4\
replace bdelay_duplicate = 0     if ndelay_duplicate == 5 & ndelay_duplicate != .\
\
gen bgmsdiag_duplicate = .\
replace bgmsdiag_duplicate = 0      if gmsdiag == 6\
replace bgmsdiag_duplicate = 1.566  if gmsdiag == 1\
replace bgmsdiag_duplicate = 1.545  if gmsdiag == 2\
replace bgmsdiag_duplicate = -0.635 if gmsdiag == 3\
replace bgmsdiag_duplicate = -0.674 if gmsdiag == 4\
replace bgmsdiag_duplicate = 0.34   if gmsdiag == 5 & gmsdiag != .\
\
gen Q = brelscor_duplicate + bcogscor_duplicate + bdelay_duplicate + bgmsdiag_duplicate\
gen logodds_duplicate = -9.53 + Q\
\
gen odds_duplicate = exp(logodds_duplicate)\
\
gen prob_duplicate = odds_duplicate / (1 + odds_duplicate)\
\
gen dem1066_duplicate = .\
replace dem1066_duplicate = 0 if prob_duplicate <= 0.25591\
replace dem1066_duplicate = 1 if prob_duplicate > 0.25591 & prob_duplicate != .\
\
summarize dem1066_duplicate dem1066\
\
tab dem1066_duplicate dem1066, miss\
\
count if dem1066_duplicate == 1\
count if cdem1066 == 1\
\
/*\
gen is_diff = 0\
replace is_diff = 1 if dem1066 != dem1066_duplicate\
drop if is_diff == 0\
*/\
\
gen is_diff = 0\
replace is_diff = 1 if (abs(relscore - relscore_duplicate) > 0.0001) & (relscore != .) & (relscore_duplicate != .)\
replace is_diff = 1 if (relscore == . & relscore_duplicate != .) | (relscore != . & relscore_duplicate == .)\
drop if is_diff == 0\
\
* Keep only the relscore and relscore_duplicate variables\
keep pid S dem1066_duplicate dem1066 misstot_duplicate relscore relscore_original relscore_duplicate is_diff ///\
 put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money\
\
* Export the modified data to an Excel file\
export excel using "/hdir/0/chrissoria/1066/differences.xlsx", firstrow(variables) replace\
\
log close\
\
}