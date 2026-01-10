********************************************************************************
* STEP 2: COGSCORE CALCULATION
* Calculate the cognitive score from prepared components
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 2: Calculating COGSCORE..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* NORMALIZE COMPONENT SCORES
* Each component is divided by its maximum possible score
*-------------------------------------------------------------------------------

gen animtot   = animals / 23    // Animal naming (max 23)
gen wordtot1  = wordimm / 3     // Immediate word recall (max 3)
gen wordtot2  = worddel / 3     // Delayed word recall (max 3)
gen papertot  = paper / 3       // Paper folding (max 3)
gen storytot  = story / 6       // Story recall (max 6)

display "Normalized component scores (should max at 1.0):"
summarize animtot wordtot1 wordtot2 papertot storytot

*-------------------------------------------------------------------------------
* CALCULATE COGSCORE
* Formula: 1.03125 * (sum of 7 components)
* Components: nametot, count, animtot, wordtot1, wordtot2, papertot, storytot
* Note: Cases with ANY missing component will have missing cogscore
*-------------------------------------------------------------------------------

gen cogscore = 1.03125 * (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot)

display _newline(1)
display "COGSCORE calculated:"
summarize cogscore

display "STEP 2 complete."
display "--------------------------------------------------------------------------------"
