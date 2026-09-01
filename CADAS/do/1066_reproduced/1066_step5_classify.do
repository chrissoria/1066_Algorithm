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
    quietly count if missing(recall) & !missing(immed)
    local n_imputed = r(N)
    replace recall = pred_recall if missing(recall) & !missing(immed)
    replace recall = 0 if recall < 0
    display "Recall imputed from immediate learning trials for `n_imputed' cases with missing recall"
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

label variable dem1066_score "10/66 dementia probability (continuous logit coefficients from 10/66 baseline, n=6791)"
label variable dem1066 "10/66 dementia classification (1=dementia, 0=no; continuous logit coefficients from 10/66 baseline)"

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA - SAMPLE-SPECIFIC QUINTILE VERSION
*-------------------------------------------------------------------------------

gen dem1066_score_quint = exp(-17.71921 + 2.76109*bcogscor_quint + 1.836585*brelscor_quint + 2.126105*bdelay_quint) / ///
                          (1 + exp(-17.71921 + 2.76109*bcogscor_quint + 1.836585*brelscor_quint + 2.126105*bdelay_quint))

gen dem1066_quint = .
replace dem1066_quint = 1 if dem1066_score_quint >= 0.5 & dem1066_score_quint != .
replace dem1066_quint = 0 if dem1066_score_quint < 0.5 & dem1066_score_quint != .

label variable dem1066_score_quint "10/66 dementia probability (sample-specific quintile coefficients from 10/66 baseline)"
label variable dem1066_quint "10/66 dementia classification (1=dementia, 0=no; sample-specific quintile coefficients)"

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA - FIXED CATEGORICAL VERSION (Original 10/66)
*-------------------------------------------------------------------------------

gen dem1066_score_categorical_orig = exp(-17.71921 + 2.76109*bcogscor + 1.836585*brelscor + 2.126105*bdelay) / ///
                                     (1 + exp(-17.71921 + 2.76109*bcogscor + 1.836585*brelscor + 2.126105*bdelay))

gen dem1066_categorical_orig = .
replace dem1066_categorical_orig = 1 if dem1066_score_categorical_orig >= 0.5 & dem1066_score_categorical_orig != .
replace dem1066_categorical_orig = 0 if dem1066_score_categorical_orig < 0.5 & dem1066_score_categorical_orig != .

label variable dem1066_score_categorical_orig "10/66 dementia probability (fixed quintile cutpoints & coefficients from 10/66 baseline)"
label variable dem1066_categorical_orig "10/66 dementia classification (1=dementia, 0=no; fixed quintile cutpoints from 10/66 baseline)"

*-------------------------------------------------------------------------------
* CALCULATE DEMENTIA - CADAS-ESTIMATED COEFFICIENTS
* Merge CDR (gold-standard clinical diagnosis), fit logit on CDR binary,
* then predict dementia probability from CADAS-estimated coefficients.
* CDR available for DR (country=1) and Cuba (country=2) only.
*-------------------------------------------------------------------------------

if $country == 1 | $country == 2 {

    * Merge CDR data
    if $country == 1 {
        merge 1:1 pid using "$data_path/dr_CDR.dta", keepusing(dr_CDR_binary) keep(master match) nogen
        rename dr_CDR_binary cdr_binary
    }
    else if $country == 2 {
        merge 1:1 pid using "$data_path/Cuba_CDR.dta", keepusing(cuba_CDR_binary) keep(master match) nogen
        rename cuba_CDR_binary cdr_binary
    }

    display _newline(1)
    display "CDR binary distribution (gold standard):"
    tab cdr_binary, miss

    * Fit logit predicting CDR from cogscore, relscore, recall
    logit cdr_binary cogscore relscore recall
    predict cadas_dem1066_score

    gen cadas_dem1066 = .
    replace cadas_dem1066 = 1 if cadas_dem1066_score >= 0.5 & cadas_dem1066_score != .
    replace cadas_dem1066 = 0 if cadas_dem1066_score < 0.5 & cadas_dem1066_score != .

    gen cadas_dem1066_ascribed = .
    replace cadas_dem1066_ascribed = 1 if cadas_dem1066_score >= 0.25 & cadas_dem1066_score != .
    replace cadas_dem1066_ascribed = 0 if cadas_dem1066_score < 0.25 & cadas_dem1066_score != .

    * Rename to country-specific variable names
    if $country == 1 {
        rename cadas_dem1066_score cadas_dem1066_score_DR
        rename cadas_dem1066 cadas_dem1066_DR
        rename cadas_dem1066_ascribed cadas_dem1066_ascribed_DR
    }

    * Save Cuba estimates so they can be applied to other countries
    if $country == 2 {
        estimates save "$data_path/cuba_1066_logit.ster", replace
        display _newline(1)
        display "Cuba logit estimates saved to: $data_path/cuba_1066_logit.ster"
    }

    * Apply Cuba-estimated coefficients to DR data
    if $country == 1 {
        capture estimates use "$cuba_path/cuba_1066_logit.ster"
        if _rc == 0 {
            display _newline(1)
            display "Applying Cuba-estimated logit coefficients to DR data..."
            predict cadas_dem1066_score
            gen cadas_dem1066 = .
            replace cadas_dem1066 = 1 if cadas_dem1066_score >= 0.5 & cadas_dem1066_score != .
            replace cadas_dem1066 = 0 if cadas_dem1066_score < 0.5 & cadas_dem1066_score != .
            gen cadas_dem1066_ascribed = .
            replace cadas_dem1066_ascribed = 1 if cadas_dem1066_score >= 0.25 & cadas_dem1066_score != .
            replace cadas_dem1066_ascribed = 0 if cadas_dem1066_score < 0.25 & cadas_dem1066_score != .
        }
        else {
            display _newline(1)
            display "WARNING: Cuba logit estimates not found at $cuba_path/cuba_1066_logit.ster"
            display "Run Cuba 1066 first to generate estimates. Variables set to missing."
            gen cadas_dem1066_score = .
            gen cadas_dem1066 = .
            gen cadas_dem1066_ascribed = .
        }
    }

    label variable cdr_binary "CDR clinical diagnosis (1=dementia CDR>0.5, 0=no CDR<=0.5)"
    if $country == 1 {
        label variable cadas_dem1066_score_DR "CADAS dementia probability (logit trained on DR CDR subsample)"
        label variable cadas_dem1066_DR "CADAS dementia classification (1=dementia, 0=no; p>=0.5, trained on DR CDR)"
        label variable cadas_dem1066_ascribed_DR "CADAS ascribed dementia (1=dementia, 0=no; p>=0.25, trained on DR CDR)"
        label variable cadas_dem1066_score "CADAS dementia probability (Cuba-estimated logit applied to DR)"
        label variable cadas_dem1066 "CADAS dementia classification (1=dementia, 0=no; p>=0.5, Cuba coefficients)"
        label variable cadas_dem1066_ascribed "CADAS ascribed dementia (1=dementia, 0=no; p>=0.25, Cuba coefficients)"
    }
    else {
        label variable cadas_dem1066_score "CADAS dementia probability (logit on CDR, CADAS-estimated coefficients)"
        label variable cadas_dem1066 "CADAS dementia classification (1=dementia, 0=no; p>=0.5, logit on CDR)"
        label variable cadas_dem1066_ascribed "CADAS ascribed dementia (1=dementia, 0=no; p>=0.25, logit on CDR)"
    }

    display _newline(1)
    display "DR-trained classification (p>=0.5):"
    if $country == 1 {
        summarize cadas_dem1066_score_DR
        tab cadas_dem1066_DR, miss
    }

    display _newline(1)
    display "Cuba-coefficients classification (p>=0.5):"
    if $country == 1 {
        summarize cadas_dem1066_score
        tab cadas_dem1066, miss
        display _newline(1)
        display "CADAS ascribed dementia - Cuba coefficients (p>=0.25):"
        tab cadas_dem1066_ascribed, miss
    }
    else {
        summarize cadas_dem1066_score
        display _newline(1)
        display "CADAS dementia classification (p>=0.5):"
        tab cadas_dem1066, miss
        display _newline(1)
        display "CADAS ascribed dementia (p>=0.25):"
        tab cadas_dem1066_ascribed, miss
    }
}
else {
    display _newline(1)
    display "NOTE: CDR data not available for this country. Skipping CADAS-estimated model."

    * Create empty variables so step 6 keep/order doesn't fail
    gen cdr_binary = .
    gen cadas_dem1066_score = .
    gen cadas_dem1066 = .
    gen cadas_dem1066_ascribed = .

    label variable cdr_binary "CDR clinical diagnosis (not available for this country)"
    label variable cadas_dem1066_score "CADAS dementia probability (not available - no CDR)"
    label variable cadas_dem1066 "CADAS dementia classification (not available - no CDR)"
    label variable cadas_dem1066_ascribed "CADAS ascribed dementia (not available - no CDR)"
}

display _newline(1)
display "Dementia probability distribution (10/66 coefficients):"
summarize dem1066_score

display _newline(1)
display "Dementia classification (10/66 coefficients):"
tab dem1066, miss

display "STEP 5 complete: Classification applied."
display "--------------------------------------------------------------------------------"
