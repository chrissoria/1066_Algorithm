clear all
capture log close
cd "/hdir/0/chrissoria/1066/"

set maxvar 100000
set more off

use "/hdir/0/chrissoria/ADAMS/DTA/ADAMS_WAVE_A_aggressive.dta", clear
count
 
**********************************
* replicate COGSCORE [10/66] and RELSCORE [10/66] in ADAMS
* started: 12/03/2021
* last update: 06/12/2024
**********************************

* Compare the 10/66 algorithm with the following measures (download links provided):

* HRS Core Interview Data
* https://hrsdata.isr.umich.edu/data-products/rand-hrs-archived-data-products
* Each individual with an HRS Core Interview record is included.

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/randhrs1992_2016v2.dta", keepusing (raeduc raracem rahispan ragender) gen(_merge5)
keep if _merge5 == 3

* Cross-Wave Imputation of Cognitive Functioning Measures: 1992-2020 (Version 3.0)
* https://hrsdata.isr.umich.edu/data-products/cross-wave-imputation-cognitive-functioning-measures-1992-2020

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/cogfinalimp_9520wide.dta", keepusing (cogtot27_imp2000 cogtot27_imp2002 cogfunction2000 cogfunction2002) gen(_merge3)
keep if _merge3 == 3

* Gianattasio-Power Predicted Dementia Probability Scores and Dementia Classifications
* https://hrsdata.isr.umich.edu/data-products/gianattasio-power-predicted-dementia-probability-scores-and-dementia-classifications

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/hrsdementia_2021_1109_2002.dta", keepusing (expert_dem hurd_dem lasso_dem hurd_p expert_p lasso_p) gen(_merge4)
keep if _merge4 == 3

destring hurd_p expert_p lasso_p, force replace

gen female = .
	replace female = 1 if ragender == 2
	replace female = 0 if ragender == 1

gen AAGE2 = AAGE * AAGE

gen AAGE_cat = .
	replace AAGE_cat = 1 if AAGE >= 70 & AAGE < 80
		replace AAGE_cat = 2 if AAGE >= 80 & AAGE < 120
gen educat = .
	replace educat = 1 if raeduc == 1 | raeduc == 2 // less than high school
	replace educat = 2 if raeduc == 3 // high school graduate
	replace educat = 3 if raeduc == 4 | raeduc == 5 // some college and above
	
gen race_cat = .
	replace race_cat = 1 if raracem == 1 & rahispan == 0
	replace race_cat = 2 if raracem == 2 & rahispan == 0
	replace race_cat = 3 if rahispan == 1

foreach i in A{

codebook `i'DFDX1

tab `i'DFDX1

cap drop dementia

gen dementia=0

replace dementia=1 if `i'DFDX1<=19

tab dementia

tab `i'DFDX1 if dementia==1 //308 with dementia

tab `i'DFDX1 if dementia==0 

tab dementia

cap drop cind

cap drop cognormal

gen cind=0

replace cind=1 if ((`i'DFDX1>19 & `i'DFDX1<=30) | `i'DFDX1==32 | `i'DFDX1==33)

tab `i'DFDX1 if cind==1 //241

tab `i'DFDX1 if cind==0

gen cognormal= 0

replace cognormal= 1 if `i'DFDX1==31

tab `i'DFDX1 if cognormal==1 //307 normal

}

****************
* COGSCORE
****************

rename ANAFTOT aANIMALS
* Animal Fluency
rename ANWM1TOT aSTORY
* Logical memory immediate recall
rename ANMSE17 aPENCIL
* Name pencil
rename ANMSE7 aREPEAT
* Sentence repeat
rename ANMSE16 aWATCH
* Name watch
rename ANMSE8 aTOWN
* town
rename ANPRES aCHIEF
* Name of political leader
rename ANMSE10 aSTREET
* name street
rename ANMSE6 aADDRESS
* name address 
rename ANMSE3 aMONTH
* recite month 
rename ANMSE5 aDAY
* recite day 
rename ANMSE1 aYEAR
* recite year
rename ANMSE2 aSEASON
* recite season
rename ANMSE22 aPENTAG
*Constructional praxis Copying

tab aPENCIL, miss


* Recode all missing values to . (missing)
* Set 98 to 0 in cogscore (98 means "incorrect" in ADAMS)
* Note: Original 10/66 data only had "correct" or "incorrect" responses, no "I don't know" option
foreach var in aPENCIL aWATCH aREPEAT aTOWN aCHIEF aSTREET aADDRESS aMONTH aDAY aYEAR aSEASON aPENTAG {
	recode `var' (97 = .)
	recode `var' (98 = 0)
	recode `var' (99 = .)
	tab `var', miss
}

foreach var in aANIMALS aSTORY{
	recode `var' (97 = .)
	tab `var', miss
} 

*recoding to make the same as 10/66
recode aWATCH 2 = 1
recode aPENCIL 2 = 1

sum aPENCIL aWATCH aREPEAT aTOWN aCHIEF aSTREET aADDRESS aMONTH aDAY aYEAR aSEASON aPENTAG
gen count = aPENCIL + aWATCH + aREPEAT + aTOWN + aCHIEF + aSTREET + aADDRESS + aMONTH + aDAY + aYEAR + aSEASON + aPENTAG

egen missing_count_cogscore = rowmiss(aPENCIL aWATCH aREPEAT aTOWN aCHIEF aSTREET aADDRESS aMONTH aDAY aYEAR aSEASON aPENTAG)
tab missing_count_cogscore

* This ensures no animtot score exceeds 1
sum aANIMALS
gen animtot=aANIMALS/33
tab animtot, miss

rename ANMSE11S aWORDIMM

foreach var in ANMSE13 ANMSE14 ANMSE15 {
	recode `var' (97 = .)
	tab `var', miss
}

gen aWORDDEL = ANMSE13 + ANMSE14 + ANMSE15
tab aWORDDEL

foreach var in ANMSE20F ANMSE20L ANMSE20R {
	recode `var' (97 = .)
	tab `var', miss
}
gen aPAPER = ANMSE20F + ANMSE20L + ANMSE20R
tab aPAPER, miss

* Check if specific variables are causing missing cogscores
sum aWORDIMM aWORDDEL aPAPER aSTORY
gen wordtot1=aWORDIMM/3
tab wordtot1, miss
gen wordtot2=aWORDDEL/3
tab wordtot2, miss
gen papertot=aPAPER/3
tab papertot, miss
gen storytot=aSTORY/37 
tab storytot, miss

* Calculate the cogscore
* Multiplying by 1.03125 is part of the original 10/66 algorithm, but not necessary for non-categorical classification
sum count animtot wordtot1 wordtot2 papertot storytot
gen COGSCORE = 1.03125*(count + animtot + wordtot1 + wordtot2 + papertot + storytot)
sum COGSCORE, d
mean COGSCORE
tab COGSCORE, miss

***********
* RELSCORE
***********

rename ADDRS1 aMEMORY
* Inability to recall recent events
gen aFRDNAME = ADDRS8 
* Forget the names of friends
gen aFAMNAME = ADDRS8
* Forget the names of family members
rename ADBL1G aLASTDAY
* Inability to recall recent events
rename ADDRS2 aORIENT
* Place: Forgets where is, generally
rename ADBL1E aLOSTOUT
* Place: Inability to find way about familiar streets
rename ADBL1D aLOSTIN
* Place: Inability to find way about indoors
rename ADBL1A aCHORES
* Difficulty performing household chores
rename ADBL1B aMONEY
* Ability to handle money
rename ADDRS3 aREASON
* Change in ability to think and reason
rename ADBL2EA aFEED
* Difficulty Eating
rename ADBL2DRE aDRESS
* Difficulty Dressing
rename ADBL2TO aTOILET
* Difficulty with Sphincter control

rename AC99 aHOBBYcs
rename ANDELCOR aRECALLcs

foreach var in aMEMORY aFRDNAME aFAMNAME aLASTDAY aORIENT aLOSTOUT aLOSTIN aCHORES aMONEY aREASON ADDRS7 ADDRS7 aFEED aDRESS aTOILET aHOBBYcs aRECALLcs{ 
recode `var' (97 = .)
recode `var' (98 = .)
recode `var' (99 = .)
}

gen aWORDFIND = ADDRS7
* Word finding difficulties.
tab aWORDFIND, miss
recode aWORDFIND (1=0) (2=.5) (3/max=1)
tab aWORDFIND, miss

gen aWORDWRG = ADDRS7
* Use the wrong words in conversations.
tab aWORDWRG, miss
recode aWORDWRG (1=0) (2=.5) (3/max=1)
tab aWORDWRG, miss

tab aMEMORY, miss
recode aMEMORY (1 2=0) (3/max=1)
tab aMEMORY, miss

tab aHOBBYcs, miss
recode aHOBBYcs (4=0) (1 2 3=1) (7 8=.)
tab aHOBBYcs, miss

tab aFRDNAME, miss
recode aFRDNAME (1 2 3=0) (4=.5) (5 6=1)
tab aFRDNAME, miss

tab aFAMNAME, miss
recode aFAMNAME (1 2 3=0) (4=.5) (5 6=1)
tab aFAMNAME, miss

tab aLASTDAY, miss
recode aLASTDAY (1=.5) (2=1)
tab aLASTDAY, miss

tab aORIENT, miss
recode aORIENT (1 2=0) (3 4=.5) (5 6=1)
tab aORIENT, miss

tab aLOSTOUT, miss
recode aLOSTOUT (1=.5) (2=1)
tab aLOSTOUT, miss

tab aLOSTIN, miss
recode aLOSTIN (1=.5) (2=1)
tab aLOSTIN, miss

tab aCHORES, miss
recode aCHORES (1=.5) (2=1)
tab aCHORES, miss

tab aMONEY, miss
recode aMONEY (1=.5) (2=1)
tab aMONEY, miss

tab aREASON, miss
recode aREASON (1 2=0) (3/max=1)
tab aREASON, miss

*max score 3
tab aFEED, miss

*max score 3
tab aDRESS, miss

*max score 3
tab aTOILET

* instances of being unable to do something because of physical disability will not be counted
rename ADBL2DRR aDRESSDIS
recode aDRESSDIS (1 2=0) (0=1)
replace aDRESS = 0 if aDRESSDIS == 1

rename ADBL2TOR aTOILETDIS
recode aTOILETDIS (1 2=0) (0=1)
replace aTOILET = 0 if aTOILETDIS == 1

rename ADBL2EAR aFEEDDIS
recode aFEEDDIS (1 2=0) (0=1)
replace aFEED =0 if aFEEDDIS == 1

rename ADBL1AR aCHORESDIS
recode aCHORESDIS (1 2=0) (0=1)
replace aCHORES = 0 if aCHORESDIS == 1

sum aMEMORY aFRDNAME aFAMNAME aWORDFIND aWORDWRG /* 
*/ aLASTDAY aORIENT aLOSTOUT aLOSTIN aCHORES aMONEY aREASON aFEED aDRESS aTOILET aHOBBYcs

egen MISS1 = rowmiss(aMEMORY aFRDNAME aFAMNAME aWORDFIND aWORDWRG aLASTDAY aORIENT aLOSTOUT aLOSTIN aCHORES aMONEY aREASON aHOBBYcs)

egen MISS3 = rowmiss(aFEED aDRESS aTOILET)

gen MISSTOT = (MISS3*3) + MISS1
summ MISS*

gen U = 23 / (23 - MISSTOT)
summ U

gen S = (cond(missing(aMEMORY), 0, aMEMORY) + ///
                    cond(missing(aFRDNAME), 0, aFRDNAME) + ///
                    cond(missing(aFAMNAME), 0, aFAMNAME) + ///
                    cond(missing(aWORDFIND), 0, aWORDFIND) + ///
                    cond(missing(aWORDWRG), 0, aWORDWRG) + ///
                    cond(missing(aLASTDAY), 0, aLASTDAY) + ///
                    cond(missing(aORIENT), 0, aORIENT) + ///
                    cond(missing(aLOSTOUT), 0, aLOSTOUT) + ///
                    cond(missing(aLOSTIN), 0, aLOSTIN) + ///
                    cond(missing(aCHORES), 0, aCHORES) + ///
                    cond(missing(aMONEY), 0, aMONEY) + ///
                    cond(missing(aREASON), 0, aREASON) + ///
                    cond(missing(aFEED), 0, aFEED) + ///
                    cond(missing(aDRESS), 0, aDRESS) + ///
                    cond(missing(aTOILET), 0, aTOILET) + ///
		    cond(missing(aHOBBYcs), 0, aHOBBYcs))

summ S		    
gen RELSCORE = (U)*S

summ RELSCORE

log using "/hdir/0/chrissoria/1066/ADAMS_1066_aggressive_98_to_0.log", text replace

drop if ADFDX1 == .

count
gen white = 0
replace white = 1 if race_cat == 1

gen black = 0
replace black = 1 if race_cat == 2

gen hispanic = 0
replace hispanic = 1 if race_cat == 3

gen college_grad = 0
replace college_grad = 1 if raeduc > 2

replace female = 0
replace female = 1 if ragender == 2

gen married = 0
replace married = 1 if AAMARRD == 2

gen core_proxy = 0
replace core_proxy = 1 if HPROXY < 5

summarize AAGE
summarize white
summarize black
summarize hispanic
summarize college_grad
summarize female
summarize married
summarize dementia
summarize AACOGSTR

/*      AACOGSTR     
	  414           1.  Low

           381           2.  Borderline

           347           3.  Low Normal

           270           4.  Moderate Normal

           358           5.  High Normal
	   
*/
summarize core_proxy

* Calculate means for the SES vars before subet
summarize AAGE white black hispanic college_grad female married dementia AACOGSTR core_proxy
matrix means = r(mean)

** set sample inclusion

egen in_samp = rowmiss(AAGE RELSCORE COGSCORE dementia cogtot27_imp2002 ragender raeduc)
egen in_samp2 = rowmiss(hurd_p expert_p lasso_p)
*525 people have no missingness across the board, mostly due to the cogscore variable
*nobody is missing age
egen in_AAGE = rowmiss(AAGE)
*nobody is missing relscore
egen in_RELSCORE = rowmiss(RELSCORE)
*927 people missing a cogscore, only 589 people have a full cogscore
egen in_COGSCORE = rowmiss(COGSCORE)
*nobody is missing the dementia score
egen in_dementia = rowmiss(dementia)
*416 people are missing this score, 1,100 people have a score
egen in_cogtot27_imp2002 = rowmiss(cogtot27_imp2002)
*nobody is missing gender or education
egen in_ragender = rowmiss(ragender)
count

preserve
keep if in_samp2 > 0 | in_samp > 0

* Calculate means for those being dropped in the subset
summarize AAGE white black hispanic college_grad female married dementia AACOGSTR core_proxy
restore

keep if in_samp == 0
count
keep if in_samp2 == 0
count

* Calculate means for the SES vars after subet
summarize AAGE white black hispanic college_grad female married dementia AACOGSTR core_proxy

* Generate frequency tables for gender, age categories, and education categories
summarize female
summarize AAGE_cat
tab AAGE_cat
summarize educat
summarize race_cat

*****     10/66    ******

*************************

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
        
        quietly logit dementia COGSCORE RELSCORE aRECALLcs if `train'
        quietly predict p_`r'_`i' if `test', pr
        
        quietly replace k_fold_dem_pred_1066_`r' = p_`r'_`i' if `test'
    }
}

gen total_pred = k_fold_dem_pred_1066_1 + k_fold_dem_pred_1066_2 + k_fold_dem_pred_1066_3 + k_fold_dem_pred_1066_4 + k_fold_dem_pred_1066_5 + k_fold_dem_pred_1066_6 + k_fold_dem_pred_1066_7 + k_fold_dem_pred_1066_8 + k_fold_dem_pred_1066_9 + k_fold_dem_pred_1066_10

gen k_fold_dem_pred_1066_av = total_pred/10
cutpt dementia k_fold_dem_pred_1066_av

* below I'm producing race-specific cutpoints
foreach r in 1 2 3 {
    preserve 
    keep if race_cat == `r'
    cutpt dementia k_fold_dem_pred_1066_av
    gen k_fold_dem_pred_1066_lat = (k_fold_dem_pred_1066_av >= .88367432) if !missing(k_fold_dem_pred_1066_av)
    roctab dementia k_fold_dem_pred_1066_lat
    tab dementia k_fold_dem_pred_1066_lat
    restore
    
    /* results:
Empirical cutpoint estimation
Method:                                Liu
Reference variable:                    dementia (0=neg, 1=pos)
Classification variable:               k_fold_dem_pred_1066_av
Empirical optimal cutpoint:            .08938869
Sensitivity at cutpoint:               0.98
Specificity at cutpoint:               0.93
Area under ROC curve at cutpoint:      0.95
(414 observations deleted)

Empirical cutpoint estimation
Method:                                Liu
Reference variable:                    dementia (0=neg, 1=pos)
Classification variable:               k_fold_dem_pred_1066_av
Empirical optimal cutpoint:            .25129401
Sensitivity at cutpoint:               0.90
Specificity at cutpoint:               0.86
Area under ROC curve at cutpoint:      0.88
(459 observations deleted)

Empirical cutpoint estimation
Method:                                Liu
Reference variable:                    dementia (0=neg, 1=pos)
Classification variable:               k_fold_dem_pred_1066_av
Empirical optimal cutpoint:            .88367432
Sensitivity at cutpoint:               1.00
Specificity at cutpoint:               1.00
Area under ROC curve at cutpoint:      1.00
*/
}

* below I'm running race-specific models to obtain race-specific probabilities 

local num_repeats 10  

foreach r in 1 2 3 {
    preserve 
    keep if race_cat == `r'
    quietly {
    forvalues n = 1/`num_repeats' {
        set seed `n'010
        gen ranum_`r' = uniform()
        sort ranum_`r'
        drop ranum_`r'
        
        gen fold_`n'_`r' = mod(_n, 10) + 1
        gen k_fold_dem_pred_1066_`n'_`r' = .
        
        display "Running iteration `n' for race category `r'"
        
        forvalues i = 1/10 {  
            local train "fold_`n'_`r' != `i'"
            local test "fold_`n'_`r' == `i'"
            
            firthlogit dementia COGSCORE RELSCORE aRECALLcs if `train'
            
            predict xb_p_`n'_`r'_`i' if `test', xb
            
            replace xb_p_`n'_`r'_`i' = 20 if xb_p_`n'_`r'_`i' > 20
            replace xb_p_`n'_`r'_`i' = -20 if xb_p_`n'_`r'_`i' < -20
            
            gen prob_`n'_`r'_`i' = 1 / (1 + exp(-xb_p_`n'_`r'_`i'))
            
            display "Predicted probabilities for iteration `n' and fold `i':"
            summarize prob_`n'_`r'_`i'
            
            replace k_fold_dem_pred_1066_`n'_`r' = prob_`n'_`r'_`i' if `test'
	}
        }
    }
    
    * Aggregate predicted probabilities across folds
    gen total_pred_`r' = 0
    forvalues i = 1/10 {
        replace total_pred_`r' = total_pred_`r' + k_fold_dem_pred_1066_`i'_`r'
    }
    keep hhidpn total_pred_`r'
    save data/total_pred_`r'.dta, replace
    restore
}

merge 1:1 hhidpn using "data/total_pred_1.dta"
drop _merge

merge 1:1 hhidpn using "data/total_pred_2.dta"
drop _merge

merge 1:1 hhidpn using "data/total_pred_3.dta"
drop _merge

gen total_pred_race_specific = total_pred_1
replace total_pred_race_specific = total_pred_2 if total_pred_race_specific == .
replace total_pred_race_specific = total_pred_3 if total_pred_race_specific == .

gen k_fold_dem_pred_1066_av_rs = total_pred_race_specific/10

* using optimal cutpoints, everyone
gen k_fold_dem_pred_1066_opt = (k_fold_dem_pred_1066_av >= .11659183) if !missing(k_fold_dem_pred_1066_av)
tab dementia k_fold_dem_pred_1066_opt, matcell(conf_matrix)
matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100
display TP+FP

display "Sensitivity for 1066 .25: " Sensitivity
display "Specificity for 1066 .25: " Specificity
display "Accuracy for 1066 .25: " Accuracy
display "Predicted Prevalence for 1066 optimal: " Prevalence

roctab dementia k_fold_dem_pred_1066_opt

matrix drop conf_matrix
scalar drop TN FN FP TP Sensitivity Specificity Accuracy Prevalence

* using ascribed cutpoint of .25, everyone

gen dem_pred_bin_1066a25 = (k_fold_dem_pred_1066_av >= .25) if !missing(k_fold_dem_pred_1066_av)

tab dem_pred_bin_1066a25
tab dementia dem_pred_bin_1066a25, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100
display TP+FP

display "Sensitivity for 1066 .25: " Sensitivity
display "Specificity for 1066 .25: " Specificity
display "Accuracy for 1066 .25: " Accuracy
display "Predicted Prevalence for 1066 .25: " Prevalence

roctab dementia dem_pred_bin_1066a25
matrix drop conf_matrix
scalar drop TN FN FP TP Sensitivity Specificity Accuracy Prevalence

* using race-specific optimal cutpoints
gen dem_pred_bin_1066_opt_rs = 0
replace dem_pred_bin_1066_opt_rs = 1 if (k_fold_dem_pred_1066_av >= .08938869) & (!missing(k_fold_dem_pred_1066_av) & race_cat == 1)
replace dem_pred_bin_1066_opt_rs = 1 if (k_fold_dem_pred_1066_av >= .25129401) & (!missing(k_fold_dem_pred_1066_av) & race_cat == 2)
replace dem_pred_bin_1066_opt_rs = 1 if (k_fold_dem_pred_1066_av >= .88367432) & (!missing(k_fold_dem_pred_1066_av) & race_cat == 3)

tab dem_pred_bin_1066_opt_rs
tab dementia dem_pred_bin_1066_opt_rs, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100
display TP+FP

display "Sensitivity for 1066 optimal race specific: " Sensitivity
display "Specificity for 1066 optimal race specific: " Specificity
display "Accuracy for 1066 optimal race specific: " Accuracy
display "Predicted Prevalence for 1066 optimal race specific: " Prevalence

roctab dementia dem_pred_bin_1066_opt_rs
matrix drop conf_matrix
scalar drop TN FN FP TP Sensitivity Specificity Accuracy Prevalence

* using ascribed cutpoint of .25 with race specific probabilities

gen dem_pred_bin_1066a25_rs = (k_fold_dem_pred_1066_av_rs >= .25) if !missing(k_fold_dem_pred_1066_av_rs)
tab dem_pred_bin_1066a25_rs
tab dementia dem_pred_bin_1066a25_rs, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100
display TP+FP

display "Sensitivity for 1066 .25 race specific: " Sensitivity
display "Specificity for 1066 .25 race specific: " Specificity
display "Accuracy for 1066 .25 race specific: " Accuracy
display "Predicted Prevalence for 1066 .25 race specific: " Prevalence

roctab dementia dem_pred_bin_1066a25_rs
matrix drop conf_matrix
scalar drop TN FN FP TP Sensitivity Specificity Accuracy Prevalence
*****  hrs, tics   ******

*************************

gen cogtot27_imp2002_binary = 2 if cogtot27_imp2002 <7
replace cogtot27_imp2002_binary = 0 if cogtot27_imp2002 >6

gen cogtot27_imp2002_categorical = 2 if cogtot27_imp2002 < 7
replace cogtot27_imp2002_categorical = 1 if cogtot27_imp2002 >= 7 & cogtot27_imp2002 < 12
replace cogtot27_imp2002_categorical = 0 if cogtot27_imp2002 >= 12

* binary cutpoint based on ascribed less than or equal to 6

gen dem_pred_lwa = 0
replace dem_pred_lwa = 1 if cogtot27_imp2002 >= 0 & cogtot27_imp2002 <= 6


tab dem_pred_lwa
tab dementia dem_pred_lwa, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100

display "Sensitivity for tics ascribed: " Sensitivity
display "Specificity for tics ascribed: " Specificity
display "Accuracy for tics ascribed: " Accuracy

display "Predicted Prevalence from HRS TICS ascribed: " Prevalence

roctab dementia dem_pred_lwa

*****  expert *****

*******************
tabulate dementia expert_dem, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100

display "Sensitivity for expert ascribed: " Sensitivity
display "Specificity for expert ascribed: " Specificity
display "Accuracy for expert ascribed: " Accuracy
display "Predicted Prevalence for expert ascribed: " Prevalence

roctab dementia expert_dem

*****  hurd  *****

******************
tabulate dementia hurd_dem, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100

display "Sensitivity for hurd ascribed: " Sensitivity
display "Specificity for hurd ascribed: " Specificity
display "Accuracy for hurd ascribed: " Accuracy
display "Predicted Prevalence for hurd ascribed: " Prevalence
roctab dementia hurd_dem

******  lasso  *******

**********************
tabulate dementia lasso_dem, matcell(conf_matrix)

matrix list conf_matrix

scalar TN = conf_matrix[1,1]
scalar FN = conf_matrix[2,1]
scalar FP = conf_matrix[1,2]
scalar TP = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)
scalar Prevalence = ((TP+FP) / (TP + TN + FP + FN))*100

display "Sensitivity for lasso ascribed: " Sensitivity
display "Specificity for lasso ascribed: " Specificity
display "Accuracy for lasso ascribed: " Accuracy
display "Predicted Prevalence for lasso ascribed: " Prevalence

roctab dementia lasso_dem

** education gradients
foreach dem_var in dementia k_fold_dem_pred_1066_opt dem_pred_bin_1066a25 dem_pred_bin_1066_opt_rs dem_pred_bin_1066a25_rs dem_pred_lwa expert_dem hurd_dem lasso_dem {
        qui: logit `dem_var' ib2.educat AAGE AAGE2 if AAGE_cat
        margins educat, post  // Only use 'post' if necessary
        eststo `dem_var'
}
** race gradients
foreach dem_var in dementia k_fold_dem_pred_1066_opt dem_pred_bin_1066a25 dem_pred_bin_1066_opt_rs dem_pred_bin_1066a25_rs dem_pred_lwa expert_dem hurd_dem lasso_dem {
        qui: logit `dem_var' ib2.race_cat AAGE AAGE2 if AAGE_cat
        margins race_cat, post  // Only use 'post' if necessary
        eststo `dem_var'
}

** tables showing proportion classified as dementia by age group

* Recode age into 5-year intervals
recode AAGE (70/74=1 "70-74") (75/79=2 "75-79") (80/84=3 "80-84") ///
                   (85/89=4 "85-89") (90/94=5 "90-94") (95/max=6 "95+"), ///
                   gen(AAGE_GROUPS)
		  
label variable AAGE_GROUPS "Age Groups (5-year intervals)"

tab AAGE_GROUPS AAGE

* bar plot for age groups only
preserve
collapse (mean) dementia_prop=dementia, by(AAGE_GROUPS)

graph bar dementia_prop, over(AAGE_GROUPS) ///
    ytitle("Proportion with Dementia") ///
    title("Proportion with Dementia by Age Group") ///
    ylabel(0(0.1)1) ///
    bar(1, color(blue))
restore
    
* bar plot for age groups and gender
preserve

collapse (mean) dementia_prop=dementia, by(AAGE_GROUPS GENDER)
graph bar dementia_prop, over(AAGE_GROUPS) by(GENDER) ///
    ytitle("Proportion with Dementia") ///
    title("Proportion with Dementia by Age Group and Gender") ///
    subtitle("") ///
    ylabel(0(0.1)1) ///
    bar(1, color(blue)) ///
    note("") ///
    legend(off)
    
restore

preserve
collapse (mean) dementia_prop=dementia, by(AAGE GENDER)

// Create the plot with smooth lines
twoway (lowess dementia_prop AAGE if GENDER == 1, lcolor(blue) lwidth(medium)) ///
       (lowess dementia_prop AAGE if GENDER == 2, lcolor(orange) lwidth(medium)) ///
       (scatter dementia_prop AAGE if GENDER == 1, mcolor(blue%30) msymbol(oh)) ///
       (scatter dementia_prop AAGE if GENDER == 2, mcolor(orange%30) msymbol(oh)), ///
       ytitle("Proportion with Dementia") ///
       xtitle("Age") ///
       title("Proportion with Clinical Diagnosis of Dementia by Age and Gender") ///
       legend(order(1 "Male" 2 "Female") rows(1) position(6) ring(1)) ///
       ylabel(0(0.1)1) ///
       xlabel(70(10)97)
       
graph export "dementia_by_age_gender.png", replace width(1000)

restore

preserve
collapse (mean) dementia_prop=dem_pred_bin_1066a25, by(AAGE GENDER)

// Create the plot with smooth lines
twoway (lowess dementia_prop AAGE if GENDER == 1, lcolor(blue) lwidth(medium)) ///
       (lowess dementia_prop AAGE if GENDER == 2, lcolor(orange) lwidth(medium)) ///
       (scatter dementia_prop AAGE if GENDER == 1, mcolor(blue%30) msymbol(oh)) ///
       (scatter dementia_prop AAGE if GENDER == 2, mcolor(orange%30) msymbol(oh)), ///
       ytitle("Proportion with Dementia") ///
       xtitle("Age") ///
       title("Proportion Ascribed 10/66 Dementia Classification by Age and Gender") ///
       legend(order(1 "Male" 2 "Female") rows(1) position(6) ring(1)) ///
       ylabel(0(0.1)1) ///
       xlabel(70(10)97)
       
graph export "1066_by_age_gender.png", replace width(1000)

restore

*tabulating to see distribution
tab AAGE_cat k_fold_dem_pred_1066_opt
tab AAGE_cat dem_pred_bin_1066a25
tab AAGE_cat dem_pred_lwa
tab AAGE_cat expert_dem
tab AAGE_cat hurd_dem
tab AAGE_cat lasso_dem
tab educat dem_pred_lwa

* Mean and SD for COGSCORE
summarize COGSCORE

* Mean and SD for RELSCORE
summarize RELSCORE

* Mean and SD for 10 Word delayed recall
summarize aRECALLcs

* Frequency distribution for Sex
tabulate ragender

* Frequency distribution for Age
tabulate AAGE_cat
summarize AAGE

* Frequency distribution for Education
tabulate educat
summarize EDYRS


keep dem_pred_bin_1066a25_rs dem_pred_bin_1066_opt_rs dem_pred_bin_1066a25 k_fold_dem_pred_1066_opt total_pred_2 k_fold_dem_pred_1066_av_rs k_fold_dem_pred_1066_av dementia race_cat ragender hhidpn
export delimited using "data/probabilities_classification.csv", replace

log close
exit, clear
