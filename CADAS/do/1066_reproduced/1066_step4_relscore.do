********************************************************************************
* STEP 4: RELSCORE CALCULATION
* Calculate the informant/relative score from prepared components
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 4: Calculating RELSCORE..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* SUM OF INFORMANT COMPONENTS (S)
* 24 items total, treating missing as 0
*-------------------------------------------------------------------------------

gen S = cond(missing(activ), 0, activ) + ///
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

*-------------------------------------------------------------------------------
* WEIGHTING FACTOR (U)
* Adjusts score based on number of missing items
* Formula: U = 30 / (30 - misstot)
*-------------------------------------------------------------------------------

gen U = 30 / (30 - misstot)
replace U = cond(missing(misstot), 0, U)
replace U = . if misstot >= 30  // Handle division by zero

*-------------------------------------------------------------------------------
* CALCULATE RELSCORE
* Formula: relscore = U * S
* This weights the sum by the proportion of non-missing items
*-------------------------------------------------------------------------------

gen relscore = U * S

*-------------------------------------------------------------------------------
* QUALITY CHECK: SET RELSCORE TO MISSING IF >50% OF ITEMS ARE MISSING
* 24 total items (21 in miss1 + 3 in miss3), so >12 missing = unreliable
*-------------------------------------------------------------------------------

gen relscore_items_missing = miss1 + miss3
replace relscore = . if relscore_items_missing > 12

* Count how many were set to missing
quietly count if relscore_items_missing > 12
local n_dropped = r(N)

display "RELSCORE calculated:"
summarize relscore
display "  Cases with >50% missing items set to missing: `n_dropped'"

display "STEP 4 complete."
display "--------------------------------------------------------------------------------"
