********************************************************************************
* STEP 5: 10/66 DEMENTIA CLASSIFICATION
* Apply the 10/66 algorithm to classify dementia cases
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 5: Applying 10/66 classification algorithm..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* OPTIONAL: IMPUTE RECALL FROM IMMEDIATE LEARNING
*-------------------------------------------------------------------------------

if "$impute_recall" == "yes" {
    gen recall_original = recall
    gen pred_recall = (0.344 * immed) - 0.339
    replace recall = pred_recall if recall == 0
    display "Recall imputed from immediate learning trials for cases with recall=0"
}

summarize recall

*-------------------------------------------------------------------------------
* CREATE FIXED QUINTILE CATEGORIES (10/66 algorithm cutpoints)
* Based on Table 5 from Prince et al. 2003
*-------------------------------------------------------------------------------

* Cognitive score categories
gen ncogscor = .
replace ncogscor = 1 if cogscore <= 23.699
replace ncogscor = 2 if cogscore > 23.699 & cogscore <= 28.619
replace ncogscor = 3 if cogscore > 28.619 & cogscore <= 30.619
replace ncogscor = 4 if cogscore > 30.619 & cogscore <= 31.839
replace ncogscor = 5 if cogscore > 31.839 & cogscore != .

* Informant score categories
gen nrelscor = .
replace nrelscor = 1 if relscore == 0
replace nrelscor = 2 if relscore > 0 & relscore <= 1.99
replace nrelscor = 3 if relscore > 1.99 & relscore <= 5.0
replace nrelscor = 4 if relscore > 5.0 & relscore <= 12.0
replace nrelscor = 5 if relscore > 12.0 & relscore != .

* Delayed recall categories
gen ndelay = .
replace ndelay = 1 if recall == 0
replace ndelay = 2 if recall >= 1 & recall <= 3
replace ndelay = 3 if recall == 4
replace ndelay = 4 if recall >= 5 & recall <= 6
replace ndelay = 5 if recall >= 7 & recall != .

*-------------------------------------------------------------------------------
* ASSIGN 10/66 ALGORITHM COEFFICIENTS (Fixed cutpoints)
* From Table 5, Prince et al. (2003)
*-------------------------------------------------------------------------------

* Cognitive score coefficients
gen bcogscor = .
replace bcogscor = 2.801  if ncogscor == 1
replace bcogscor = 1.377  if ncogscor == 2
replace bcogscor = 0.866  if ncogscor == 3
replace bcogscor = -0.231 if ncogscor == 4
replace bcogscor = 0      if ncogscor == 5

* Informant score coefficients
gen brelscor = .
replace brelscor = 0     if nrelscor == 1
replace brelscor = 1.908 if nrelscor == 2
replace brelscor = 2.311 if nrelscor == 3
replace brelscor = 4.171 if nrelscor == 4
replace brelscor = 5.680 if nrelscor == 5

* Delayed recall coefficients
gen bdelay = .
replace bdelay = 3.822 if ndelay == 1
replace bdelay = 3.349 if ndelay == 2
replace bdelay = 2.575 if ndelay == 3
replace bdelay = 2.176 if ndelay == 4
replace bdelay = 0     if ndelay == 5

*-------------------------------------------------------------------------------
* SAMPLE-SPECIFIC QUINTILES
*-------------------------------------------------------------------------------

xtile ncogscor_quint = cogscore, nq(5)
xtile nrelscor_quint = relscore, nq(5)
xtile ndelay_quint = recall, nq(5)

* Assign coefficients based on sample-specific quintiles
gen bcogscor_quint = .
replace bcogscor_quint = 2.801  if ncogscor_quint == 1
replace bcogscor_quint = 1.377  if ncogscor_quint == 2
replace bcogscor_quint = 0.866  if ncogscor_quint == 3
replace bcogscor_quint = -0.231 if ncogscor_quint == 4
replace bcogscor_quint = 0      if ncogscor_quint == 5 & ncogscor_quint != .

gen brelscor_quint = .
replace brelscor_quint = 0     if nrelscor_quint == 1
replace brelscor_quint = 1.908 if nrelscor_quint == 2
replace brelscor_quint = 2.311 if nrelscor_quint == 3
replace brelscor_quint = 4.171 if nrelscor_quint == 4
replace brelscor_quint = 5.680 if nrelscor_quint == 5 & nrelscor_quint != .

gen bdelay_quint = .
replace bdelay_quint = 3.822 if ndelay_quint == 1
replace bdelay_quint = 3.349 if ndelay_quint == 2
replace bdelay_quint = 2.575 if ndelay_quint == 3
replace bdelay_quint = 2.176 if ndelay_quint == 4
replace bdelay_quint = 0     if ndelay_quint == 5 & ndelay_quint != .

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA PROBABILITY - CONTINUOUS VERSION
* Logistic regression formula from 10/66 algorithm
*-------------------------------------------------------------------------------

gen dem1066_score = exp(8.486511 - 0.4001659*cogscore + 0.5024221*relscore - 0.6997248*recall) / ///
                    (1 + exp(8.486511 - 0.4001659*cogscore + 0.5024221*relscore - 0.6997248*recall))

gen dem1066 = .
replace dem1066 = 1 if dem1066_score >= 0.5 & dem1066_score != .
replace dem1066 = 0 if dem1066_score < 0.5 & dem1066_score != .

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA - SAMPLE-SPECIFIC QUINTILE VERSION
*-------------------------------------------------------------------------------

gen dem1066_score_quint = exp(-17.71921 + 2.76109*bcogscor_quint + 1.836585*brelscor_quint + 2.126105*bdelay_quint) / ///
                          (1 + exp(-17.71921 + 2.76109*bcogscor_quint + 1.836585*brelscor_quint + 2.126105*bdelay_quint))

gen dem1066_quint = .
replace dem1066_quint = 1 if dem1066_score_quint >= 0.5 & dem1066_score_quint != .
replace dem1066_quint = 0 if dem1066_score_quint < 0.5 & dem1066_score_quint != .

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA - FIXED CATEGORICAL VERSION (Original 10/66)
*-------------------------------------------------------------------------------

gen dem1066_score_categorical_orig = exp(-17.71921 + 2.76109*bcogscor + 1.836585*brelscor + 2.126105*bdelay) / ///
                                     (1 + exp(-17.71921 + 2.76109*bcogscor + 1.836585*brelscor + 2.126105*bdelay))

gen dem1066_categorical_orig = .
replace dem1066_categorical_orig = 1 if dem1066_score_categorical_orig >= 0.5 & dem1066_score_categorical_orig != .
replace dem1066_categorical_orig = 0 if dem1066_score_categorical_orig < 0.5 & dem1066_score_categorical_orig != .

display "Dementia probability distribution:"
summarize dem1066_score

display _newline(1)
display "Dementia classification:"
tab dem1066, miss

display "STEP 5 complete: Classification applied."
display "--------------------------------------------------------------------------------"
