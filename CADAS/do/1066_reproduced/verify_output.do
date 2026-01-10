********************************************************************************
* VERIFICATION: Run refactored 10/66 algorithm and display key outputs
********************************************************************************

clear all
set more off

display _newline(2)
display "================================================================================"
display "RUNNING REFACTORED 10/66 ALGORITHM"
display "================================================================================"

do "/Users/chrissoria/Documents/Research/1066/CADAS/do/1066_reproduced/1066_master.do"

display _newline(2)
display "================================================================================"
display "VERIFICATION OUTPUTS"
display "================================================================================"

display _newline(1)
display "1. SAMPLE SIZE:"
count
count if !missing(dem1066)
display "   Total observations: " r(N)

display _newline(1)
display "2. COGSCORE:"
summarize cogscore, detail

display _newline(1)
display "3. RELSCORE:"
summarize relscore, detail

display _newline(1)
display "4. RECALL:"
summarize recall, detail

display _newline(1)
display "5. DEM1066_SCORE (probability):"
summarize dem1066_score, detail

display _newline(1)
display "6. DEM1066 CLASSIFICATION:"
tab dem1066, miss

display _newline(1)
display "7. COMPONENT SCORES:"
summarize nametot count animtot wordtot1 wordtot2 papertot storytot

display _newline(1)
display "8. RELSCORE COMPONENTS:"
summarize S U misstot

display _newline(1)
display "9. QUINTILE DISTRIBUTIONS:"
display "   Cognitive score quintiles:"
tab ncogscor, miss
display "   Relscore quintiles:"
tab nrelscor, miss
display "   Delay quintiles:"
tab ndelay, miss

display _newline(2)
display "================================================================================"
display "VERIFICATION COMPLETE"
display "================================================================================"
display "Compare these values against expected outputs from original algorithm."
display "Key values to check:"
display "  - Mean cogscore should be ~28.7 for Cuba"
display "  - Mean relscore should be ~1.8 for Cuba"
display "  - dem1066 prevalence should be ~3.5% for Cuba"
display "================================================================================"
