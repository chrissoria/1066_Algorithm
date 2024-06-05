{\rtf1\ansi\ansicpg1252\cocoartf2761
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 ArialMT;}
{\colortbl;\red255\green255\blue255;\red24\green25\blue27;\red255\green255\blue255;}
{\*\expandedcolortbl;;\cssrgb\c12549\c12941\c14118;\cssrgb\c100000\c100000\c100000;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab720
\pard\pardeftab720\partightenfactor0

\f0\fs26 \cf2 \cb3 \expnd0\expndtw0\kerning0
clear all \
set more off\
capture log close\
cls\
\
*******ADJUST LOCALS HERE**********\
\
***********************************\
local user "Chris"  // Change this to "Will" to switch paths\
\
*for now just using Cuba\
local Chris "/hdir/0/chrissoria/Stata_CADAS/Data/DR_out"\
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
use "`path'/Cog.dta"\
*until we clean all the data, we'll have to indiscriminantly drop duplicates\
duplicates report pid\
sort pid\
by pid: gen dup = _n == 1\
drop if dup == 0\
drop dup\
\
merge 1:m pid using Infor, force\
duplicates report pid\
sort pid\
by pid: gen dup = _n == 1\
drop if dup == 0\
drop dup\
\
rename _merge merge1\
\
merge 1:m pid using Cog_Scoring, force\
duplicates report pid\
sort pid\
by pid: gen dup = _n == 1\
drop if dup == 0\
drop dup\
\
duplicates report pid\
\
rename c_24 pencil\
rename c_25 watch\
rename c_48 chair\
rename c_49 shoes\
rename c_50 knuckle\
rename c_51 elbow\
rename c_52 should\
rename c_53 bridge\
rename c_54 hammer\
rename c_55 pray\
rename c_56 chemist\
rename c_26 repeat\
rename c_8 town\
gen chief = cond(missing(c_70_d_c),0,c_70_d_c) + cond(missing(c_70_p),0,c_70_p)\
rename i_a2 street\
rename i_a3 store\
rename i_a4 address\
gen longmem = cond(missing(c_69_c),0,c_69_c) + cond(missing(c_69_d),0,c_69_d) + cond(missing(c_69_p),0,c_69_p)\
rename c_3 month\
rename c_5 day\
rename c_1 year\
gen season = cond(missing(c_2_p_c),0,c_2_p_c) + cond(missing(c_2_d),0,c_2_d)\
rename c_61 nod\
rename c_62 point\
rename cs_72_1 circle\
rename c_72_1 circle_diss\
rename cs_32 pentag\
rename c_32 pentag_diss\
rename cs_40 animals\
rename c_40 animals_diss\
gen wordimm = c_11 + c_12 + c_13\
gen worddel = c_21 + c_22 + c_23\
\
foreach var in c_27 c_28 c_29 \{\
	replace `var' = . if `var' == 6 | `var' == 7\
\}\
gen paper = cond(missing(c_27),0,c_27) + cond(missing(c_28),0,c_28) + cond(missing(c_29),0,c_29)\
\
foreach var in c_66a c_66b c_66c c_66d c_66e c_66f \{\
	tab `var'\
	replace `var' = 1 if `var' == 0 | `var' == 1\
	replace `var' = 0 if `var' == 2\
	summarize `var'\
\}\
gen story = c_66a + c_66b + c_66c + c_66d + c_66e + c_66f\
\
rename c_66_a story_refuse\
gen learn1 = c_33_1 + c_33_2 + c_33_3 + c_33_4 + c_33_5 + c_33_6 + c_33_7 + c_33_8 + c_33_9 + c_33_10\
rename c_33_a learn1_refuse\
gen learn2 = c_34_1 + c_34_2 + c_34_3 + c_34_4 + c_34_5 + c_34_6 + c_34_7 + c_34_8 + c_34_9 + c_34_10\
rename c_34_a learn2_refuse\
gen learn3 = c_35_1 + c_35_2 + c_35_3 + c_35_4 + c_35_5 + c_35_6 + c_35_7 + c_35_8 + c_35_9 + c_35_10\
rename c_35_a learn3_refuse\
gen recall = c_63_1 + c_63_2 + c_63_3 + c_63_4 + c_63_5 + c_63_6 + c_63_7 + c_63_8 + c_63_9 + c_63_10\
rename c_63_a recall_refuse\
rename c_0 name\
rename c_65 nrecall\
\
foreach var in story learn1 learn2 learn3 recall \{\
	replace `var' = . if `var'_refuse == 7\
\}\
\
*for now, we will recode physical disability into missing (but later we could keep as 1)\
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point \{\
	replace `var' = . if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9\
\}\
replace circle = . if circle_diss == 6 | circle_diss == 7\
replace circle = 0 if circle == 1\
replace circle = 1 if circle == 2\
replace circle = 1 if circle == 3\
\
replace pentag = . if pentag_diss == 6 | pentag_diss == 7\
replace pentag = 1 if pentag == 2\
\
replace animals = . if animals == 777\
*for now, until we decide acceptable cutpoint\
replace animals = . if animals > 45\
\
gen nametot = 0\
replace nametot = 1 if name > 0 & !missing(name)\
replace nametot = 1 if nrecall > 0 & !missing(nrecall)\
\
foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall \{\
    replace `var' = . if `var' == .v | `var' == .i\
\}\
\
egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)\
\
*max should be 27\
summarize count\
\
*this is only if we want to impute recall (which I don't think we want to)\
gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)\
tab recall, miss\
*we could potentially recover 59 cases here\
tab immed, miss\
\
*dividing by total amount of possible correct answers to get a "total"\
\
local divide_var "animals wordimm worddel paper story"\
local divisor "45 3 3 3 6"\
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
*all of these should max out to 1\
summarize animtot\
summarize wordtot1\
summarize wordtot2\
summarize papertot\
summarize storytot\
\
\
* generate the cogscore. anyone who does not have all components will be dropped.\
gen cogscore = nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot\
\
summarize cogscore\
\
***** relscore ********\
\
***********************\
\
rename i_f_csid_1 activ\
rename i_f_csid_2 mental\
rename i_f_csid_3 memory\
rename i_f_csid_4 put\
rename i_f_csid_5 kept\
rename i_f_csid_6 frdname\
rename i_f_csid_7 famname\
rename i_f_csid_8 convers\
rename i_f_csid_9 wordfind\
rename i_f_csid_10 wordwrg\
rename i_f_csid_11 past\
rename i_f_csid_12 lastsee\
rename i_f_csid_13 lastday\
rename i_f_csid_14 orient\
rename i_f_csid_15 lostout\
rename i_f_csid_16 lostin\
rename i_f_csid_17 chores\
rename i_f_csid_18 hobby\
rename i_f_csid_19 money\
rename i_f_csid_20 change\
rename i_f_csid_21 reason\
rename i_f_csid_22_1 feed\
rename i_f_csid_22_2 feeddiss\
rename i_f_csid_23_1 dress\
rename i_f_csid_23_2 dressdiss\
rename i_f_csid_24_1 toilet\
rename i_f_csid_24_2 toiletdiss\
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
egen miss1 = rowtotal(missing_mental missing_activ missing_memory /* \
    */ missing_put missing_kept missing_frdname missing_famname /* \
    */ missing_convers missing_wordfind missing_wordwrg missing_past /* \
    */ missing_lastsee missing_lastday missing_orient missing_lostout /* \
    */ missing_lostin missing_chores missing_hobby missing_money /* \
    */ missing_change missing_reason)\
\
\
* counting up the remaining missing values to generate miss 3 variable\
local miss3_variables "feed dress toilet"\
\
gen miss3 = 0\
\
foreach var of local miss3_variables \{\
    * Sum up the variables that are missing\
    replace miss3 = miss3 + missing(`var')\
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
replace miss1 = . if (all_miss ==24 & miss3 == .)\
\
gen misstot = (miss3 * 3) + miss1\
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
gen S_2 = activ + mental + memory + put + kept + ///\
 frdname + famname + convers + wordfind + wordwrg + past + lastsee + lastday + ///\
 orient + lostout + lostin + chores + hobby + money + change + reason + feed + ///\
 dress + toilet\
 \
gen T_2 = miss1_duplicate + miss3_duplicate\
 \
gen U_2 = 30 / (30 - misstot_duplicate)\
\
gen relscore_duplicate = (U) * S - ((T) * 9)\
gen relscore_duplicate2 = (U_2) * S_2 - ((T_2) * 9)\
\
summarize relscore_duplicate relscore_duplicate2 relscore_original\
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
 put kept frdname famname convers wordfind wordwrg past lastsee lastday orient lostout lostin chores chores_original change money\
\
* Export the modified data to an Excel file\
export excel using "/hdir/0/chrissoria/1066/differences.xlsx", firstrow(variables) replace\
\
log close\
\
}