********************************************************************************
* STEP 0.5: CREATE ALL VARIABLES NEEDED FOR ANALYSIS
* Renames, recodes, and constructs cogscore, relscore, and component variables
********************************************************************************

capture log close step05
log using "$log_path/step0.5_create_vars.log", replace name(step05)

* Load data from previous step
use "$within_path/cadas_within_data.dta", clear

display _newline(2)
display "================================================================================"
display "STEP 0.5: CREATE ALL VARIABLES NEEDED FOR ANALYSIS"
display "================================================================================"
display _newline(1)

*-------------------------------------------------------------------------------
* COGNITIVE VARIABLES - Renaming and recoding
*-------------------------------------------------------------------------------

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

* Chief variable - country-specific
gen chief = .
replace chief = cond(missing(c_70_d_c), 0, c_70_d_c)

rename i_a2 street
rename i_a3 store
rename i_a4 address

* Longmem - country-specific
gen longmem = .
replace longmem = cond(missing(c_69_c),0,c_69_c) + cond(missing(c_69_d),0,c_69_d)

rename c_3 month
rename c_5 day
rename c_1 year

* Season - country-specific
gen season = .
replace season = cond(missing(c_2_p_c),0,c_2_p_c) + cond(missing(c_2_d),0,c_2_d)

rename c_61 nod
rename c_62 point

* Circle variable - recode to binary (0 or 1), set missing for disability/refusal
rename cs_72_2 circle
rename c_72_2 circle_diss
replace circle = . if circle_diss == 6 | circle_diss == 7
replace circle = 0 if circle == 7 | circle == 8 | circle == 9
replace circle = 1 if circle > 1 & circle != .

rename cs_32_cleaned pentag
rename c_32 pentag_diss
rename cs_40 animals
rename c_40 animals_diss

* Word immediate and delayed recall
foreach var in c_11 c_12 c_13 c_21 c_22 c_23 {
    replace `var' = 0 if `var' ==.i
}

gen wordimm = c_11 + c_12 + c_13
gen worddel = c_21 + c_22 + c_23

* Paper folding - recode refusals to 0
foreach var in c_27 c_28 c_29 {
    replace `var' = 0 if `var' == 6 | `var' == 7
}
gen paper = cond(missing(c_27),0,c_27) + cond(missing(c_28),0,c_28) + cond(missing(c_29),0,c_29)

* Story recall
foreach var in c_66a c_66b c_66c c_66d c_66e c_66f {
    replace `var' = 1 if `var' == 0 | `var' == 1
    replace `var' = 0 if `var' == 2
    replace `var' = 0 if `var' == .i
}
gen story = c_66a + c_66b + c_66c + c_66d + c_66e + c_66f

rename c_66_a story_refuse

* Learning trials and recall
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

* Set to missing if refused
foreach var in story learn1 learn2 learn3 recall {
    replace `var' = . if `var'_refuse == 7
}

* Handle physical disability codes (6, 7, 8, 9) - recode to 0
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
    replace `var' = 0 if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9
}

replace pentag = . if pentag_diss == 6 | pentag_diss == 7

* Street, store, address come from informant - recode 2 to 0
recode street (2 = 0)
recode store (2 = 0)
recode address (2 = 0)

replace pentag = 1 if pentag == 2

replace animals = . if animals == 777
replace animals = . if animals > 45
replace animals = . if animals_diss == 777

* Name total
gen nametot = 0
replace nametot = 1 if name > 0 & !missing(name)
replace nametot = 1 if nrecall > 0 & !missing(nrecall)

* Remove valid and invalid skips
foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall {
    capture replace `var' = . if `var' == .v | `var' == .i
}

* Count variable (sum of binary items) - max should be 28
egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)

* Immediate recall total (for imputation)
gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)

* Create proportion scores
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

* Generate cogscore
gen cogscore = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)

display "COGSCORE created:"
summarize cogscore

*-------------------------------------------------------------------------------
* RELSCORE VARIABLES - Renaming and recoding
*-------------------------------------------------------------------------------

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

* Create missing indicators for miss1 variables
local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"

foreach var of local miss1_variables {
    gen missing_`var' = missing(`var')
}

egen miss1 = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason)

* Create missing indicators for miss3 variables
local miss3_variables "feed dress toilet"

gen miss3 = 0

foreach var of local miss3_variables {
    replace miss3 = miss3 + missing(`var')
}

foreach var in feed dress toilet {
    gen missing_`var' = missing(`var')
}

egen all_miss = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason missing_feed missing_dress missing_toilet)

replace miss1 = . if (all_miss == 24 & miss3 == .)

gen misstot = (miss3 * 3) + miss1

* Divide by 2 for specific variables
foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money reason {
    replace `var'= `var'/2
}

* Recode if disability
replace dress = 0 if dressdiss == 1
replace chores = 0 if choredis == 1
replace feed = 0 if feeddiss == 1
replace toilet = 0 if toildiss == 1

* Calculate S (sum of relscore components)
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

* Calculate U (weighting factor)
gen U = 30 / (30 - misstot)
replace U = cond(missing(misstot), 0, U)

* Calculate relscore
gen relscore = U * S

display "RELSCORE created:"
summarize relscore

*-------------------------------------------------------------------------------
* RECALL IMPUTATION (optional)
*-------------------------------------------------------------------------------

* Impute recall from immediate if requested
* Note: This uses the impute_recall global from master file
if "$impute_recall" == "yes" {
    gen recall_original = recall
    gen pred_recall = (0.344 * immed) - 0.339
    replace recall = pred_recall if recall == 0
    display "Recall imputed from immediate recall"
}

display _newline(1)
display "STEP 0.5 complete. Variables created:"
display "  - Cognitive: cogscore, nametot, count, animtot, wordtot1, wordtot2, papertot, storytot"
display "  - Relscore: relscore, S, U, misstot, miss1, miss3"
display "  - Learning: learn1, learn2, learn3, recall, immed"
display "--------------------------------------------------------------------------------"

* Save dataset with all variables created
save "$within_path/cadas_within_data.dta", replace

log close step05
