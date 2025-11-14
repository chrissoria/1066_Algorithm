clear all 
set more off
capture log close
cls

*******ADJUST LOCALS HERE**********

***********************************
local user "Chris"  // Change this to "Will" to switch paths
local country "CU"

*for now just using Cuba
if "`country'" == "CU" {
local Chris "/Users/chrissoria/Documents/CADAS/Data/CUBA_out"
}

else if "`country'" == "DR" {
local Chris "/Users/chrissoria/Documents/CADAS/Data/DR_out"
}


local Will "PATH"

local path = cond("`user'" == "Chris", "`Chris'", "`Will'")

cd "`path'"

local wave 1

local drop_missing_from_relscore "no" // change to yes or no
local drop_physical_disability "no"
local impute_recall "yes" //imputes the 10-word delayed recall from the immediate recall questions

*create a dummy for people that we recoded because of that disability


***** SCRIPT STARTS HERE *********

**********************************

use "`path'/Cog.dta"
*until we clean all the data, we'll have to indiscriminantly drop duplicates
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

merge 1:m pid using Infor, force
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

rename _merge merge1

merge 1:m pid using Cog_Scoring, force
duplicates report pid
sort pid
by pid: gen dup = _n == 1
drop if dup == 0
drop dup

duplicates report pid

rename c_24 pencil
rename c_25 watch
rename c_48 chair
rename c_49 shoes
rename c_50 knuckle
rename c_51 elbow
rename c_52 should
rename c_53 bridge
rename c_54 hammer
rename c_55 pray
rename c_56 chemist
rename c_26 repeat
rename c_8 town
gen chief = .
if inlist("`country'", "CU", "DR") {
    replace chief = cond(missing(c_70_d_c), 0, c_70_d_c)
}
else {
    replace chief = cond(missing(c_70_p), 0, c_70_p)
}
rename i_a2 street
rename i_a3 store
rename i_a4 address
gen longmem = .
if inlist("`country'", "CU", "DR") {
    replace longmem = cond(missing(c_69_c),0,c_69_c) + cond(missing(c_69_d),0,c_69_d)
}
else {
    replace longmem = cond(missing(c_69_p),0,c_69_p)
}

rename c_3 month
rename c_5 day
rename c_1 year
gen season = .
if inlist("`country'", "CU", "DR") {
    replace season = cond(missing(c_2_p_c),0,c_2_p_c) + cond(missing(c_2_d),0,c_2_d)
}
else {
    replace season = cond(missing(c_2_p_c),0,c_2_p_c)
}
rename c_61 nod
rename c_62 point
rename cs_32 pentag
rename c_32 pentag_diss
rename cs_40 animals
rename c_40 animals_diss

foreach var in c_11 c_12 c_13 c_21 c_22 c_23 {
	replace `var' = 0 if `var' ==.i
}

gen wordimm = c_11 + c_12 + c_13
gen worddel = c_21 + c_22 + c_23

*for now coding to 0
foreach var in c_27 c_28 c_29 {
	replace `var' = 0 if `var' == 6 | `var' == 7
}
gen paper = cond(missing(c_27),0,c_27) + cond(missing(c_28),0,c_28) + cond(missing(c_29),0,c_29)

foreach var in c_66a c_66b c_66c c_66d c_66e c_66f {
	tab `var'
	replace `var' = 1 if `var' == 0 | `var' == 1
	replace `var' = 0 if `var' == 2
	replace `var' = 0 if `var' == .i
	summarize `var'
}
gen story = c_66a + c_66b + c_66c + c_66d + c_66e + c_66f

summarize story

rename c_66_a story_refuse
gen learn1 = c_33_1 + c_33_2 + c_33_3 + c_33_4 + c_33_5 + c_33_6 + c_33_7 + c_33_8 + c_33_9 + c_33_10
rename c_33_a learn1_refuse
gen learn2 = c_34_1 + c_34_2 + c_34_3 + c_34_4 + c_34_5 + c_34_6 + c_34_7 + c_34_8 + c_34_9 + c_34_10
rename c_34_a learn2_refuse
gen learn3 = c_35_1 + c_35_2 + c_35_3 + c_35_4 + c_35_5 + c_35_6 + c_35_7 + c_35_8 + c_35_9 + c_35_10
rename c_35_a learn3_refuse
gen recall = c_63_1 + c_63_2 + c_63_3 + c_63_4 + c_63_5 + c_63_6 + c_63_7 + c_63_8 + c_63_9 + c_63_10
rename c_63_a recall_refuse
rename c_0 name
rename c_65 nrecall

foreach var in story learn1 learn2 learn3 recall {
	replace `var' = . if `var'_refuse == 7
}

if "`drop_physical_disability'" == "yes" {
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
	replace `var' = . if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9
}

}

if "`drop_physical_disability'" == "no" {
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
	replace `var' = 0 if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9
}

}

if "`drop_physical_disability'" == "yes" {
replace pentag = . if pentag_diss == 6 | pentag_diss == 7
}

else if "`drop_physical_disability'" == "no" {
replace pentag = 0 if pentag_diss == 6 | pentag_diss == 7
}

*street, store, and address come from informant and therefore have a different structure
recode street (2 = 0)
recode store (2 = 0)
recode address (2 = 0)

replace pentag = 1 if pentag == 2

replace animals = . if animals == 777
* copying from original algo
replace animals = . if animals > 45

gen nametot = 0
replace nametot = 1 if name > 0 & !missing(name)
replace nametot = 1 if nrecall > 0 & !missing(nrecall)

*both types of skips (valid and invalid) will be removed
foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point  pentag nametot nrecall {
    replace `var' = . if `var' == .v | `var' == .i
}

egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point pentag)

*max should be 27
summarize count

*this is only if we want to impute recall (which I don't think we want to)
gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)
tab recall, miss
tab immed, miss

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

*all of these should max out to 1
summarize animtot
summarize wordtot1
summarize wordtot2
summarize papertot
summarize storytot


* generate the cogscore. anyone who does not have all components will be dropped.
gen cogscore = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)

summarize cogscore

/* in CU the averae cogscore is 28.70772 
in DR the average cogscore is 27.34616

in 1066 it's 26.13309
*/

***** relscore ********

***********************

rename i_f_csid_1 activ
rename i_f_csid_2 mental
rename i_f_csid_3 memory
rename i_f_csid_4 put
rename i_f_csid_5 kept
rename i_f_csid_6 frdname
rename i_f_csid_7 famname
rename i_f_csid_8 convers
rename i_f_csid_9 wordfind
rename i_f_csid_10 wordwrg
rename i_f_csid_11 past
rename i_f_csid_12 lastsee
rename i_f_csid_13 lastday
rename i_f_csid_14 orient
rename i_f_csid_15 lostout
rename i_f_csid_16 lostin
rename i_f_csid_17 chores
rename i_f_csid_17a choredis
rename i_f_csid_18 hobby
rename i_f_csid_19 money
rename i_f_csid_20 change
rename i_f_csid_21 reason
rename i_f_csid_22_1 feed
rename i_f_csid_22_2 feeddiss
rename i_f_csid_23_1 dress
rename i_f_csid_23_2 dressdiss
rename i_f_csid_24_1 toilet
rename i_f_csid_24_2 toildiss

* Creating binary missing indicators without changing the original missing values
local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"

* Creating new binary variables for each original variable to indicate whether the value is missing
foreach var of local miss1_variables {
    gen missing_`var' = missing(`var')
}

* Generating the miss1 variable by summing up the binary missing indicators
egen miss1 = rowtotal(missing_mental missing_activ missing_memory /* 
    */ missing_put missing_kept missing_frdname missing_famname /* 
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* 
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* 
    */ missing_lostin missing_chores missing_hobby missing_money /* 
    */ missing_change missing_reason)


* counting up the remaining missing values to generate miss 3 variable
local miss3_variables "feed dress toilet"

gen miss3 = 0

foreach var of local miss3_variables {
    * Sum up the variables that are missing
    replace miss3 = miss3 + missing(`var')
}

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
    
replace miss1 = . if (all_miss ==24 & miss3 == .)

gen misstot = (miss3 * 3) + miss1

/* below should be the correct logic
replace misstot = . if misstot == 30
replace misstot = 0 if misstot == .

replace misstot_duplicate = . if misstot_duplicate == 30
replace misstot_duplicate = 0 if misstot_duplicate == .

*/

summarize misstot
summarize miss1
summarize miss3

foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money reason {
    replace `var'= `var'/2
}

if `wave' == 2 {
replace chores = chores_original
}

*this whole chunk of code produces no changes
* Backup original 'dress' variable and recode if 'dressdis' is 1
replace dress = 0 if dressdis == 1

* Backup original 'chores' variable and recode if 'choredis' is 1
replace chores = 0 if choredis == 1

* Backup original 'feed' variable and recode if 'feeddis' is 1
replace feed = 0 if feeddis == 1

* Backup original 'toilet' variable and recode if 'toildis' is 1
replace toilet = 0 if toildis == 1

*replace misstot_duplicate = 0 if misstot_duplicate == .

if "`drop_missing_from_relscore'" == "yes" {
    drop if misstot > 0
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

gen U = 30 / (30 - misstot)
replace U = cond(missing(misstot), 0, U)

gen relscore_cadas = U*S

summarize activ mental memory put kept frdname famname convers ///
         wordfind wordwrg past lastsee lastday orient lostout ///
         lostin chores hobby money change reason feed dress toilet

summarize relscore
/* our relscore in DR is bigger than 10/66 by over a whole point.  
in Cuba: 1.794301

score in 10/66:

     Variable |        Obs        Mean    Std. dev.       Min        Max
-------------+---------------------------------------------------------
relscore_d~e |      6,825    2.267357    4.131984          0         30
relscore_o~l |      6,799    2.271145    4.129672  -9.310345         30
*/

summarize recall
/* in CU the average recall is 3.432124 
in DR the average recall is 2.318493
*/

if "`impute_recall'" == "yes" {
	gen recall_original = recall

	gen pred_recall = (0.344 * immed) - 0.339
    
	replace recall = pred_recall if recall == 0
}

* HERE, I WILL CONVERT THE CONTINOUS VARIABLES WE HAVE INTO QUINTILE CATEGORICALS
* Create cognitive score categories
gen ncogscor = .
replace ncogscor = 1 if cogscore <= 23.699
replace ncogscor = 2 if cogscore > 23.699 & cogscore <= 28.619
replace ncogscor = 3 if cogscore > 28.619 & cogscore <= 30.619
replace ncogscor = 4 if cogscore > 30.619 & cogscore <= 31.839
replace ncogscor = 5 if cogscore > 31.839 & cogscore != .

* Assign cognitive coefficients (from Table 5)
gen bcogscor = .
replace bcogscor = 2.801  if ncogscor == 1
replace bcogscor = 1.377  if ncogscor == 2
replace bcogscor = 0.866  if ncogscor == 3
replace bcogscor = -0.231 if ncogscor == 4
replace bcogscor = 0      if ncogscor == 5

* Create informant score categories
gen nrelscor = .
replace nrelscor = 1 if relscore == 0
replace nrelscor = 2 if relscore > 0 & relscore <= 1.99
replace nrelscor = 3 if relscore > 1.99 & relscore <= 5.0
replace nrelscor = 4 if relscore > 5.0 & relscore <= 12.0
replace nrelscor = 5 if relscore > 12.0 & relscore != .

* Assign informant coefficients (from Table 5)
gen brelscor = .
replace brelscor = 0     if nrelscor == 1
replace brelscor = 1.908 if nrelscor == 2
replace brelscor = 2.311 if nrelscor == 3
replace brelscor = 4.171 if nrelscor == 4
replace brelscor = 5.680 if nrelscor == 5

* Create delayed recall categories
gen ndelay = .
replace ndelay = 1 if recall == 0
replace ndelay = 2 if recall >= 1 & recall <= 3
replace ndelay = 3 if recall == 4
replace ndelay = 4 if recall >= 5 & recall <= 6
replace ndelay = 5 if recall >= 7 & recall != .

* Assign recall coefficients (from Table 5)
gen bdelay = .
replace bdelay = 3.822 if ndelay == 1
replace bdelay = 3.349 if ndelay == 2
replace bdelay = 2.575 if ndelay == 3
replace bdelay = 2.176 if ndelay == 4
replace bdelay = 0     if ndelay == 5

* For cognitive score quintiles
xtile ncogscor_quint = cogscore, nq(5)

* For informant score quintiles
xtile nrelscor_quint = relscore, nq(5)

* For delayed recall quintiles
xtile ndelay_quint = recall, nq(5)

* 1066 formulas

gen dem1066_score = exp(8.486511 -.4001659 * cogscore + .5024221 * relscore -.6997248 * recall) / (1 + exp(8.486511 -.4001659 * cogscore + .5024221 * relscore -.6997248 * recall))

gen dem1066 = .
replace dem1066 = 1 if dem1066_score >= .5 & dem1066_score != .
replace dem1066 = 0 if dem1066_score <.5 & dem1066_score != .

summarize dem1066
*DR dem1066_du~e |      6,783    .1167625    .3211607          0          1
*CU CADAS dem1066 |        911    .0351262       .1842          0          1

*the below is only for analyzing the output
/*
keep pid relscore cogscore nametot count animals_diss animals animtot wordtot1 wordtot2 papertot c_66a c_66b c_66c c_66d c_66e c_66f story storytot pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town street store address month day year nod point pentag pentag_diss animals animals_diss chief longmem season c_11 c_12 c_13 wordimm c_21 c_22 c_23 worddel misstot activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet recall dem1066_score dem1066

order pid relscore cogscore nametot count animals_diss animals animtot wordtot1 wordtot2 papertot c_66a c_66b c_66c c_66d c_66e c_66f story storytot pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town street store address month day year nod point pentag pentag_diss animals animals_diss chief longmem season c_11 c_12 c_13 wordimm c_21 c_22 c_23 worddel misstot activ mental memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason feed dress toilet recall dem1066_score dem1066
*/
