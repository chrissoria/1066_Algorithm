********************************************************************************
* STEP 6: SAVE OUTPUT
* Keep relevant variables and save to 1066.dta and excel/1066.xlsx
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 6: Saving output..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* KEEP RELEVANT VARIABLES
*-------------------------------------------------------------------------------

keep pid relscore cogscore nametot count animals_diss animals animtot ///
     wordtot1 wordtot2 paper papertot c_66a c_66b c_66c c_66d c_66e c_66f story ///
     storytot pencil watch chair shoes knuckle elbow should bridge hammer ///
     pray chemist repeat town street store address month day year nod point ///
     circle circle_diss pentag pentag_diss pentag_strict chief longmem season c_11 c_12 ///
     c_13 wordimm c_21 c_22 c_23 worddel miss1 miss3 misstot activ mental memory put ///
     kept frdname famname convers wordfind wordwrg past lastsee lastday ///
     orient lostout lostin chores hobby money change reason feed dress ///
     toilet recall dem1066_score dem1066 dem1066_score_quint dem1066_quint immed ///
     learn1 learn2 learn3

*-------------------------------------------------------------------------------
* ORDER VARIABLES
*-------------------------------------------------------------------------------

order pid relscore cogscore nametot count animals_diss animals animtot ///
      wordtot1 wordtot2 paper papertot c_66a c_66b c_66c c_66d c_66e c_66f story ///
      storytot pencil watch chair shoes knuckle elbow should bridge hammer ///
      pray chemist repeat town street store address month day year nod point ///
      circle circle_diss pentag pentag_diss pentag_strict chief longmem season c_11 c_12 ///
      c_13 wordimm c_21 c_22 c_23 worddel miss1 miss3 misstot activ mental memory put ///
      kept frdname famname convers wordfind wordwrg past lastsee lastday ///
      orient lostout lostin chores hobby money change reason feed dress ///
      toilet recall dem1066_score dem1066 dem1066_score_quint dem1066_quint immed ///
      learn1 learn2 learn3

*-------------------------------------------------------------------------------
* EXPORT TO EXCEL
*-------------------------------------------------------------------------------

capture mkdir excel
export excel using "excel/1066.xlsx", replace firstrow(variables)

*-------------------------------------------------------------------------------
* SAVE STATA FILE
*-------------------------------------------------------------------------------

save 1066.dta, replace

display "STEP 6 complete: Data saved."
display "  - 1066.dta"
display "  - excel/1066.xlsx"
display "--------------------------------------------------------------------------------"
