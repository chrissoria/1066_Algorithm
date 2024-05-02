*classifying 98 to 0 in the cogscore
*98 in the ADAMS data means I don't know (incorrect)
*however, the original 10/66 didn't provide an i don't know response (just correct or incorrect)
*the decision is to A. recode to incorrect or B. recode to missing
*in the previous version I recoded to missing, in this version I will recode to incorrect

clear all
capture log close
cd "/hdir/0/chrissoria/1066/"

set maxvar 100000
set more off

use "/hdir/0/chrissoria/ADAMS/DTA/ADAMS_WAVE_A_aggressive.dta", clear

 
**********************************
* replicate COGSCORE [10/66] and RELSCORE [10/66] in ADAMS
* started: 12/03/2021
* last update: 08/01/2023
**********************************

**

/*First I'm going to create the langa-weir 27-point score using the existing the ADAMS data.
The 27-point scale includes: 1) immediate and delayed 10-noun free recall test to measure
memory (0 to 20 points); 2) a serial sevens subtraction test to measure working memory (0 to 5
points); and 3) a counting backwards test to measure speed of mental processing (0 to 2 points).

Backwards Count starting from 20 and 86

ANIMMCR1 = 10 point immediate recall sum (first attempt)
ANDELCOR = 10 point delayed recall sum
ANSER7T = 0-5 point serial sevens score
ANBWC201 = 0-1 score for counting backwards from 20
ANBWC861 = 0-1 score for counting backwards from 86

*/

*we're comparing these algorithms

** https://hrsdata.isr.umich.edu/data-products/rand-hrs-archived-data-products
* Every individual who has ever completed an HRS Core Interview has a record in this file.
merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/randhrs1992_2016v2.dta", keepusing (raeduc raracem rahispan ragender) gen(_merge5)
keep if _merge5 == 3
**

**https://hrsdata.isr.umich.edu/data-products/cross-wave-imputation-cognitive-functioning-measures-1992-2020
* The Cross-Wave Imputation of Cognitive Functioning Measures: 1992-2020 (Final, Version 3.0) data release contains imputations for cognitive functioning data for HRS 1992 through 2020.

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/cogfinalimp_9520wide.dta", keepusing (cogtot27_imp2000 cogtot27_imp2002 cogfunction2000 cogfunction2002) gen(_merge3)
keep if _merge3 == 3
**

/* https://hrsdata.isr.umich.edu/data-products/gianattasio-power-predicted-dementia-probability-scores-and-dementia-classifications
Gianattasio-Power Predicted Dementia Probability Scores and Dementia Classifications

*/

merge 1:1 hhidpn using "/hdir/0/chrissoria/ADAMS/DTA/hrsdementia_2021_1109_2002.dta", keepusing (expert_dem hurd_dem lasso_dem hurd_p expert_p lasso_p) gen(_merge4)
keep if _merge4 == 3
**

destring hurd_p expert_p lasso_p, force replace

gen female = .
	replace female = 1 if ragender == 2
	replace female = 0 if ragender == 1

gen AAGE2 = AAGE * AAGE

gen AAGE_cat = .
	replace AAGE_cat = 1 if AAGE >= 70 & AAGE < 80
		replace AAGE_cat = 2 if AAGE >= 80 & AAGE < 120
gen educat = .
	replace educat = 1 if raeduc == 1 | raeduc == 2
	replace educat = 2 if raeduc == 3
	replace educat = 3 if raeduc == 4 | raeduc == 5

*chris adding this in based on Jordan's instruction

foreach i in A{

*variable BDFDX1 not found
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

*chris adding this
rename ANAFTOT aANIMALS
rename ANWM1TOT aSTORY
rename ANMSE17 aWATCH
rename ANMSE7 aREPEAT
rename ANMSE16 aPENCIL
rename ANMSE8 aTOWN
rename ANPRES aCHIEF
rename ANMSE10 aSTREET
rename ANMSE6 aADDRESS
rename ANMSE3 aMONTH
rename ANMSE5 aDAY
rename ANMSE1 aYEAR
rename ANMSE2 aSEASON
rename ANMSE22 aPENTAG


*recoding everything that's reported as missing for whatever reason as missing  
foreach var in aPENCIL aWATCH aREPEAT aTOWN aCHIEF aSTREET aADDRESS aMONTH aDAY aYEAR aSEASON aPENTAG {
	recode `var' (97 = .)
	recode `var' (98 = .)
	recode `var' (99 = .)
	tab `var', miss
}

foreach var in aANIMALS aSTORY{
	recode `var' (97 = .)
	tab `var', miss
} 

*below is what already was (haven't added two variables i found

sum aPENCIL aWATCH aREPEAT aTOWN aCHIEF aSTREET aADDRESS aMONTH aDAY aYEAR aSEASON aPENTAG
gen count = aPENCIL + aWATCH + aREPEAT + aTOWN + aCHIEF + aSTREET + aADDRESS + aMONTH + aDAY + aYEAR + aSEASON + aPENTAG

*I changed the 23 to 33 based on the survey question
* if we leave as 23 some people will have a score for animtot that's greater than 1
sum aANIMALS
gen animtot=aANIMALS/33
tab animtot, miss

*****chris adding this*****
rename ANMSE11S aWORDIMM
*there's three of these, I'm choosing the first delayed recall
rename ANMSE13 aWORDDEL
foreach var in ANMSE20F ANMSE20L ANMSE20R {
	recode `var' (97 = .)
	tab `var', miss
}
gen aPAPER = ANMSE20F + ANMSE20L + ANMSE20R
tab aPAPER, miss

*check to see if there's one or two variables driving the missing
sum aWORDIMM aWORDDEL aPAPER aSTORY
gen wordtot1=aWORDIMM/3
tab wordtot1, miss
gen wordtot2=aWORDDEL/3
tab wordtot2, miss
gen papertot=aPAPER/3
tab papertot, miss
gen storytot=aSTORY/37 
tab storytot, miss

sum count animtot wordtot1 wordtot2 papertot storytot
gen COGSCORE = 1.03125*(count + animtot + wordtot1 + wordtot2 + papertot + storytot)
sum COGSCORE, d
mean COGSCORE
tab COGSCORE, miss

***********
* RELSCORE
***********

***chris adding this***
rename ADDRS1 aMEMORY
gen aFRDNAME = ADDRS8 
gen aFAMNAME = ADDRS8
rename ADBL1G aLASTDAY
rename ADDRS2 aORIENT
rename ADBL1E aLOSTOUT
rename ADBL1D aLOSTIN
rename ADBL1A aCHORES
rename ADBL1B aMONEY
rename ADDRS3 aREASON
rename ADBL2EA aFEED
rename ADBL2DRE aDRESS
rename ADBL2TO aTOILET

/*removing for now
*****variables chris found*****
* these comes from the informant questionairre which would require us to drop over 100 cases
rename AGQ20 aPUTcs
rename AGQ19 aKEPTcs
*/
*this comes from section C which has a high response rate
rename AC99 aHOBBYcs
rename ANDELCOR aRECALLcs

foreach var in aMEMORY aFRDNAME aFAMNAME aLASTDAY aORIENT aLOSTOUT aLOSTIN aCHORES aMONEY aREASON ADDRS7 ADDRS7 aFEED aDRESS aTOILET aHOBBYcs aRECALLcs{ 
recode `var' (97 = .)
recode `var' (98 = .)
recode `var' (99 = .)
}

*recoding according to what's in the excel document
*I made this so that they are how the SPSS document wants it
gen aWORDFIND = ADDRS7
tab aWORDFIND, miss
recode aWORDFIND (1=0) (2=.5) (3/max=1)
tab aWORDFIND, miss

gen aWORDWRG = ADDRS7
tab aWORDWRG, miss
recode aWORDWRG (1=0) (2=.5) (3/max=1)
tab aWORDWRG, miss

tab aMEMORY, miss
recode aMEMORY (1 2=0) (3/max=1)
tab aMEMORY, miss

/*
tab aPUTcs, miss
recode aPUTcs (1 2 3=0) (4=.5) (5=1)
tab aPUTcs, miss

tab aKEPTcs, miss
recode aKEPTcs (1 2 3=0) (4=.5) (5=1)
tab aKEPTcs, miss


tab aKEPT, miss
recode aKEPT (1 2 3=0) (4=.5) (5=1)
tab aKEPT, miss
*/

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

*now let's cancel out in case of physical disabiity
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

*this only works after we recode everything and have all variables (we have to change the 30 to 25 if we use the variables i added in)
* and X if we don't add them in
gen U = 23 / (23 - MISSTOT)
summ U
*max S should be 25
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

log using "/hdir/0/chrissoria/1066/ADAMS_1066_aggressive.log", text replace

** set sample inclusion
egen in_samp = rowmiss(AAGE RELSCORE COGSCORE dementia cogtot27_imp2002 ragender raeduc)
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
keep if in_samp == 0
count
egen in_samp2 = rowmiss(hurd_p expert_p lasso_p)

keep if in_samp2 == 0
count

** table 2 **
tab female
tab AAGE_cat
tab educat


** table 3 **

******  1066    ******

**********************

logit dementia COGSCORE RELSCORE aRECALLcs
gen inreg1066=e(sample)
predict dem_pred_1066
estat classification, cutoff(.25)
estat classification, cutoff(.50)
estat classification, cutoff(.12903368)
cutpt dementia dem_pred_1066

*optimal
rocreg dementia dem_pred_1066
	gen dem_pred_bin_1066 = (dem_pred_1066 >= .12903368) if !missing(dem_pred_1066)
tab dementia dem_pred_bin_1066, matcell(conf_matrix)
display "Predicted Prevalence from 1066 optimal cutoff: " (93/469) * 100

*ascribed
gen dem_pred_bin_1066a50= (dem_pred_1066 >= .5) if !missing(dem_pred_1066)
tab dem_pred_bin_1066a50
tab dementia dem_pred_bin_1066a50, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for 1066 .5: " Sensitivity
display "Specificity for 1066 .5: " Specificity
display "Accuracy for 1066 .5: " Accuracy
display "Predicted Prevalence for 1066 .5: " ((TP+FP) / (TP + TN + FP + FN))*100

roctab dementia dem_pred_bin_1066a50

display "Predicted Prevalence from 1066 .5 cutoff: " (75/469) * 100

gen dem_pred_bin_1066a25 = (dem_pred_1066 >= .25) if !missing(dem_pred_1066)
tab dem_pred_bin_1066a25
tab dementia dem_pred_bin_1066a25, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for 1066 .25: " Sensitivity
display "Specificity for 1066 .25: " Specificity
display "Accuracy for 1066 .25: " Accuracy
display "Predicted Prevalence for 1066 .25: " ((TP+FP) / (TP + TN + FP + FN))*100
roctab dementia dem_pred_bin_1066a25


*****  hrs, tics   *******

**************************

gen cogtot27_imp2002_binary = 2 if cogtot27_imp2002 <7
replace cogtot27_imp2002_binary = 0 if cogtot27_imp2002 >6

gen cogtot27_imp2002_categorical = 2 if cogtot27_imp2002 < 7
replace cogtot27_imp2002_categorical = 1 if cogtot27_imp2002 >= 7 & cogtot27_imp2002 < 12
replace cogtot27_imp2002_categorical = 0 if cogtot27_imp2002 >= 12

logit dementia cogtot27_imp2002
gen inregtics=e(sample)
predict dem_pred_lw
estat classification, cutoff(.13094532)
cutpt dementia dem_pred_lw

rocreg dementia dem_pred_lw
	gen dem_pred_bin_lw = (dem_pred_lw >= .13094532) if !missing(dem_pred_lw)
tab dementia dem_pred_bin_lw

display "Predicted Prevalence from HRS TICS optimal cutoff: " (166/469) * 100

gen dem_pred_lwa = 0
	replace dem_pred_lwa = 1 if cogtot27_imp2002 >= 0 & cogtot27_imp2002 <= 6


tab dem_pred_lwa
tab dementia dem_pred_lwa, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for tics ascribed: " Sensitivity
display "Specificity for tics ascribed: " Specificity
display "Accuracy for tics ascribed: " Accuracy

display "Predicted Prevalence from HRS TICS ascribed: " ((TP+FP) / (TP + TN + FP + FN))*100
roctab dementia dem_pred_lwa

*****  expert *****

*******************
logit dementia expert_p
gen inregexpert=e(sample)
predict dem_pred_expert
estat classification, cutoff(.5)
estat classification, cutoff(.08421316)
cutpt dementia dem_pred_expert

display "Predicted Prevalence from expert optimal cutoff: " (132/469) * 100

*optimal
rocreg dementia dem_pred_expert
	gen dem_pred_bin_expert = (dem_pred_expert >= .08421316) if !missing(dem_pred_expert)
tab dementia dem_pred_bin_expert

*ascribed
gen dem_pred_experta = (dem_pred_expert >= .5) if !missing(dem_pred_expert)
tab dem_pred_experta
tab dementia dem_pred_experta, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for expert ascribed: " Sensitivity
display "Specificity for expert ascribed: " Specificity
display "Accuracy for expert ascribed: " Accuracy
display "Predicted Prevalence for expert ascribed: " ((TP+FP) / (TP + TN + FP + FN))*100

roctab dementia dem_pred_experta


******  hurd  ********

**********************

logit dementia hurd_p
gen inreghurd=e(sample)
predict dem_pred_hurd
estat classification, cutoff(.5)
estat classification, cutoff(.07790542)
cutpt dementia dem_pred_hurd
display "Predicted Prevalence from hurd optimal cutoff: " (143/469) * 100

*optimal
rocreg dementia dem_pred_hurd
	gen dem_pred_bin_hurd = (dem_pred_hurd >= .07790542) if !missing(dem_pred_hurd)
tab dementia dem_pred_bin_hurd

*ascribed
gen dem_pred_hurda = (dem_pred_hurd >= .5) if !missing(dem_pred_hurd)
tab dem_pred_hurda
tab dementia dem_pred_hurda, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for hurd ascribed: " Sensitivity
display "Specificity for hurd ascribed: " Specificity
display "Accuracy for hurd ascribed: " Accuracy
display "Predicted Prevalence for hurd ascribed: " ((TP+FP) / (TP + TN + FP + FN))*100
roctab dementia dem_pred_hurda

******  lasso  *******

**********************

logit dementia lasso_p
gen inreglasso=e(sample)
predict dem_pred_lasso
estat classification, cutoff(.5)
estat classification, cutoff(.14725079)
cutpt dementia dem_pred_lasso
display "Predicted Prevalence from lasso optimal cutoff: " (96/469) * 100

*optimal
rocreg dementia dem_pred_lasso
	gen dem_pred_bin_lasso = (dem_pred_lasso >= .14725079) if !missing(dem_pred_lasso)
tab dementia dem_pred_bin_lasso

*ascribed (.9010816)
gen dem_pred_lassoa = (dem_pred_lasso >= .5) if !missing(dem_pred_lasso)
tab dem_pred_lassoa
tab dementia dem_pred_lassoa, matcell(conf_matrix)

matrix list conf_matrix

scalar TP = conf_matrix[1,1]
scalar FN = conf_matrix[1,2]
scalar FP = conf_matrix[2,1]
scalar TN = conf_matrix[2,2]

scalar Sensitivity = TP / (TP + FN)
scalar Specificity = TN / (TN + FP)
scalar Accuracy = (TP + TN) / (TP + TN + FP + FN)

display "Sensitivity for lasso ascribed: " Sensitivity
display "Specificity for lasso ascribed: " Specificity
display "Accuracy for lasso ascribed: " Accuracy
display "Predicted Prevalence for lasso ascribed: " ((TP+FP) / (TP + TN + FP + FN))*100

roctab dementia dem_pred_lassoa

** education gradients [optimal cutpoints]
foreach dem_var in dementia dem_pred_bin_1066 dem_pred_bin_lw dem_pred_bin_expert dem_pred_bin_hurd dem_pred_bin_lasso {
forvalues r=1/2 {
display "****start: `dem_var' `r'****"
qui: logit `dem_var' ib2.educat AAGE AAGE2 if AAGE_cat == `r'
	margins educat, post
	eststo `dem_var'_`r'
	}
}

*in this data there are zero cases of dem_pred_experta if AAGE_CAT == 1
*same thing for dem_pred_hurda and dem_pred_lassoa
*I will remove it for now and ask Jordan about it
tab AAGE_cat dem_pred_experta
tab AAGE_cat dem_pred_hurda
tab AAGE_cat dem_pred_lassoa

** education gradients [ascribed]
foreach dem_var in dementia dem_pred_bin_1066a25 dem_pred_bin_1066a50 dem_pred_lwa dem_pred_experta dem_pred_hurda dem_pred_lassoa{
forvalues r=1/2 {
display "****start: `dem_var' `r'****"
qui: logit `dem_var' ib2.educat AAGE AAGE2 if AAGE_cat == `r'
	margins educat, post
	eststo `dem_var'_`r'
	}
}


log close
exit, clear

