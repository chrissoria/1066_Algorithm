********************************************************************************
* STEP 3: RELSCORE PREPARATION
* Rename and recode all informant-reported variables needed for RELSCORE
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 3: Preparing relative/informant score components..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* RENAME INFORMANT VARIABLES (24 items total)
*-------------------------------------------------------------------------------

* Cognitive/behavioral items (21 items)
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

* ADL items (3 items with disability indicators)
rename i_f_csid_22_1 feed
rename i_f_csid_22_2 feeddiss
rename i_f_csid_23_1 dress
rename i_f_csid_23_2 dressdiss
rename i_f_csid_24_1 toilet
rename i_f_csid_24_2 toildiss

*-------------------------------------------------------------------------------
* CREATE MISSING INDICATORS
*-------------------------------------------------------------------------------

* Missing indicators for 21 cognitive/behavioral items
local miss1_variables "mental activ memory put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores hobby money change reason"

foreach var of local miss1_variables {
    gen missing_`var' = missing(`var')
}

* Sum of missing for 21 items
egen miss1 = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason)

* Missing indicators for 3 ADL items
local miss3_variables "feed dress toilet"

gen miss3 = 0
foreach var of local miss3_variables {
    replace miss3 = miss3 + missing(`var')
}

foreach var in feed dress toilet {
    gen missing_`var' = missing(`var')
}

* Total missing across all 24 items
egen all_miss = rowtotal(missing_mental missing_activ missing_memory /*
    */ missing_put missing_kept missing_frdname missing_famname /*
    */ missing_convers missing_wordfind missing_wordwrg missing_past /*
    */ missing_lastsee missing_lastday missing_orient missing_lostout /*
    */ missing_lostin missing_chores missing_hobby missing_money /*
    */ missing_change missing_reason missing_feed missing_dress missing_toilet)

* Set miss1 to missing if all items are missing
replace miss1 = . if (all_miss == 24 & miss3 == .)

* Calculate total missing score (ADL items weighted 3x)
gen misstot = (miss3 * 3) + miss1

display "Missing data summary:"
summarize miss1 miss3 misstot

*-------------------------------------------------------------------------------
* RESCALE ITEMS (divide by 2 for items scored 0-2)
*-------------------------------------------------------------------------------

foreach var in put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores change money {
    replace `var' = `var' / 2
}

*-------------------------------------------------------------------------------
* RECODE REASON TO BINARY
* Note: In the original 1066 data, reason is binary (0=no change, 1=yes change).
* In CADAS, reason has 3 levels (0=no, 1=sometimes, 2=regularly).
* We collapse to binary to match the original 1066 structure, since the
* coefficients were trained on binary values. This recode is not needed
* in the original 1066 algorithm but is required for CADAS alignment.
*-------------------------------------------------------------------------------

replace reason = 1 if reason == 2

*-------------------------------------------------------------------------------
* HANDLE DISABILITY RECODING
* If disability is present, recode functional item based on global setting
* Options: "zero" = recode to 0, "missing" = recode to missing
*-------------------------------------------------------------------------------

if "$recode_disability_to" == "missing" {
    replace dress = . if dressdiss == 1
    replace chores = . if choredis == 1
    replace feed = . if feeddiss == 1
    replace toilet = . if toildiss == 1
    display "Relscore disability items recoded to MISSING"
}
else {
    replace dress = 0 if dressdiss == 1
    replace chores = 0 if choredis == 1
    replace feed = 0 if feeddiss == 1
    replace toilet = 0 if toildiss == 1
    display "Relscore disability items recoded to ZERO"
}

*-------------------------------------------------------------------------------
* OPTIONAL: DROP CASES WITH MISSING RELSCORE ITEMS
*-------------------------------------------------------------------------------

if "$drop_missing_from_relscore" == "yes" {
    drop if misstot > 0
    display "Dropped cases with missing relscore items"
}

display "STEP 3 complete: Informant components prepared."
display "--------------------------------------------------------------------------------"
