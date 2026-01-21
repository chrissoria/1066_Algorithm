********************************************************************************
* STEP 1: COGSCORE PREPARATION
* Rename and recode all cognitive test variables needed for COGSCORE
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 1: Preparing cognitive score components..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* BINARY COGNITIVE TEST ITEMS (26 items for 'count' variable)
*-------------------------------------------------------------------------------

* Object naming
rename c_24 pencil
rename c_25 watch
rename c_48 chair
rename c_49 shoes
rename c_50 knuckle
rename c_51 elbow
rename c_52 should
rename c_53 bridge
rename c_54 hammer
rename c_55 pray
rename c_56 chemist

* Repetition
rename c_26 repeat

* Orientation - place
rename c_8 town

* Chief/president naming (PR uses c_70_p; Cuba and DR use c_70_d_c)
gen chief = .
if $country == 0 {
    replace chief = cond(missing(c_70_p), 0, c_70_p)
}
else {
    replace chief = cond(missing(c_70_d_c), 0, c_70_d_c)
}

* Informant-reported memory items
rename i_a2 street
rename i_a3 store
rename i_a4 address

* Long-term memory (PR uses c_69_p; Cuba and DR use c_69_c + c_69_d)
gen longmem = .
if $country == 0 {
    replace longmem = cond(missing(c_69_p), 0, c_69_p)
}
else {
    replace longmem = cond(missing(c_69_c),0,c_69_c) + cond(missing(c_69_d),0,c_69_d)
    replace longmem = 1 if longmem > 1 & !missing(longmem)
}

* Orientation - time
rename c_3 month
rename c_5 day
rename c_1 year

* Season (PR uses c_2_p_c; Cuba and DR use c_2_p_c + c_2_d)
gen season = .
if $country == 0 {
    replace season = cond(missing(c_2_p_c), 0, c_2_p_c)
}
else {
    replace season = cond(missing(c_2_p_c),0,c_2_p_c) + cond(missing(c_2_d),0,c_2_d)
    replace season = 1 if season > 1 & !missing(season)
}

* Motor commands
rename c_61 nod
rename c_62 point

* Circle drawing - recode to binary
rename cs_72_1 circle
rename c_72_1 circle_diss
* Disability codes handled below in conditional block
replace circle = 1 if circle > 1 & circle != .

* Pentagon drawing (requires Ty's cleaned scoring)
capture confirm variable cs_32_cleaned
if _rc != 0 {
    display as error "ERROR: cs_32_cleaned not found. Re-run Cog_Scoring_Read.do to generate this variable."
    error 111
}
rename cs_32_cleaned pentag
rename c_32 pentag_diss

* Animal naming
rename cs_40 animals
rename c_40 animals_diss

*-------------------------------------------------------------------------------
* WORD RECALL COMPONENTS
*-------------------------------------------------------------------------------

* Handle missing indicators for word recall items
foreach var in c_11 c_12 c_13 c_21 c_22 c_23 {
    replace `var' = 0 if `var' == .i
}

* Immediate word recall (3 trials summed)
gen wordimm = c_11 + c_12 + c_13

* Delayed word recall (3 trials summed)
gen worddel = c_21 + c_22 + c_23

*-------------------------------------------------------------------------------
* PAPER FOLDING
*-------------------------------------------------------------------------------

* Recode disability (6 = could not) to 0, refusal (7) to missing
foreach var in c_27 c_28 c_29 {
    replace `var' = 0 if `var' == 6
    replace `var' = . if `var' == 7
}

gen paper = cond(missing(c_27),0,c_27) + cond(missing(c_28),0,c_28) + cond(missing(c_29),0,c_29)

*-------------------------------------------------------------------------------
* STORY RECALL
*-------------------------------------------------------------------------------

* Recode story elements to binary
foreach var in c_66a c_66b c_66c c_66d c_66e c_66f {
    replace `var' = 1 if `var' == 0 | `var' == 1
    replace `var' = 0 if `var' == 2
    replace `var' = 0 if `var' == .i
}

gen story = c_66a + c_66b + c_66c + c_66d + c_66e + c_66f
rename c_66_a story_refuse

*-------------------------------------------------------------------------------
* LEARNING TRIALS AND DELAYED RECALL
*-------------------------------------------------------------------------------

* Learning trial 1 (10 words)
gen learn1 = c_33_1 + c_33_2 + c_33_3 + c_33_4 + c_33_5 + c_33_6 + c_33_7 + c_33_8 + c_33_9 + c_33_10
rename c_33_a learn1_refuse

* Learning trial 2
gen learn2 = c_34_1 + c_34_2 + c_34_3 + c_34_4 + c_34_5 + c_34_6 + c_34_7 + c_34_8 + c_34_9 + c_34_10
rename c_34_a learn2_refuse

* Learning trial 3
gen learn3 = c_35_1 + c_35_2 + c_35_3 + c_35_4 + c_35_5 + c_35_6 + c_35_7 + c_35_8 + c_35_9 + c_35_10
rename c_35_a learn3_refuse

* Delayed recall (10 words)
gen recall = c_63_1 + c_63_2 + c_63_3 + c_63_4 + c_63_5 + c_63_6 + c_63_7 + c_63_8 + c_63_9 + c_63_10
rename c_63_a recall_refuse

* Name recall
rename c_0 name
rename c_65 nrecall

* Set to missing if refused
foreach var in story learn1 learn2 learn3 recall {
    replace `var' = . if `var'_refuse == 7
}

*-------------------------------------------------------------------------------
* HANDLE PHYSICAL DISABILITY vs REFUSAL CODES
* Disability (6, 8, 9 = could not due to physical limitation) → recode to 0
* Refusal (7 = refused) → recode to missing
*-------------------------------------------------------------------------------

* Binary cognitive items: disability → 0, refusal → missing
foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
    replace `var' = 0 if `var' == 6 | `var' == 8 | `var' == 9
    replace `var' = . if `var' == 7
}

* Pentagon: disability → 0, refusal → missing
replace pentag = 0 if pentag_diss == 6
replace pentag = . if pentag_diss == 7

* Circle: disability → 0, refusal → missing
replace circle = 0 if circle_diss == 6
replace circle = . if circle_diss == 7
replace circle = 0 if circle == 8 | circle == 9
replace circle = . if circle == 7

display "Disability codes (6, 8, 9) recoded to ZERO; Refusal codes (7) recoded to MISSING"

* Informant items: recode 2 to 0
recode street (2 = 0)
recode store (2 = 0)
recode address (2 = 0)

* Pentagon: ensure binary
* Create strict version for reference (only value 2 = correct)
gen pentag_strict = (pentag == 2) if !missing(pentag)

* Apply scoring based on option
if "$use_strict_pentag" == "yes" {
    * Strict scoring: only value 2 counts as correct (matches 1066 baseline)
    replace pentag = 0 if pentag == 1
    replace pentag = 1 if pentag == 2
    display "Pentagon scoring: STRICT (only value 2 = correct)"
}
else {
    * Lenient scoring: both 1 and 2 count as correct
    replace pentag = 1 if pentag == 2
    display "Pentagon scoring: LENIENT (values 1 and 2 = correct)"
}

* Animals: handle out of range values
replace animals = . if animals == 777
replace animals = . if animals > 45
replace animals = . if animals_diss == 777

*-------------------------------------------------------------------------------
* NAME TOTAL
*-------------------------------------------------------------------------------

gen nametot = 0
replace nametot = 1 if name > 0 & !missing(name)
replace nametot = 1 if nrecall > 0 & !missing(nrecall)

*-------------------------------------------------------------------------------
* HANDLE VALID/INVALID SKIPS
*-------------------------------------------------------------------------------

foreach var in animals wordimm worddel paper story learn1 learn2 learn3 recall pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag nametot nrecall {
    replace `var' = . if `var' == .v | `var' == .i
}

*-------------------------------------------------------------------------------
* COUNT VARIABLE (sum of 26 binary cognitive items)
*-------------------------------------------------------------------------------

egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)

display "Count variable created (max should be 26):"
summarize count

*-------------------------------------------------------------------------------
* IMMEDIATE RECALL TOTAL (for potential imputation)
*-------------------------------------------------------------------------------

gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)

display "STEP 1 complete: Cognitive components prepared."
display "--------------------------------------------------------------------------------"
