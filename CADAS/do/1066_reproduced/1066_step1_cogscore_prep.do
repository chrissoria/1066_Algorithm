********************************************************************************
* STEP 1: COGSCORE PREPARATION
* Rename and recode all cognitive test variables needed for COGSCORE
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 1: Preparing cognitive score components..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* BINARY COGNITIVE TEST ITEMS (28 items for 'count' variable)
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

* Chief/president naming (Cuba and DR use c_70_d_c)
gen chief = .
replace chief = cond(missing(c_70_d_c), 0, c_70_d_c)

* Informant-reported memory items
rename i_a2 street
rename i_a3 store
rename i_a4 address

* Long-term memory (Cuba and DR) - cap at 1 for binary
gen longmem = .
replace longmem = cond(missing(c_69_c),0,c_69_c) + cond(missing(c_69_d),0,c_69_d)
replace longmem = 1 if longmem > 1 & !missing(longmem)

* Orientation - time
rename c_3 month
rename c_5 day
rename c_1 year

* Season (Cuba and DR) - cap at 1 for binary
gen season = .
replace season = cond(missing(c_2_p_c),0,c_2_p_c) + cond(missing(c_2_d),0,c_2_d)
replace season = 1 if season > 1 & !missing(season)

* Motor commands
rename c_61 nod
rename c_62 point

* Circle drawing - recode to binary
rename cs_72_2 circle
rename c_72_2 circle_diss
replace circle = . if circle_diss == 6 | circle_diss == 7
replace circle = 0 if circle == 7 | circle == 8 | circle == 9
replace circle = 1 if circle > 1 & circle != .

* Pentagon drawing
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

* Recode refusals to 0
foreach var in c_27 c_28 c_29 {
    replace `var' = 0 if `var' == 6 | `var' == 7
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
* HANDLE PHYSICAL DISABILITY CODES
* Options: "zero" = recode to 0, "missing" = recode to missing
*-------------------------------------------------------------------------------

if "$recode_disability_to" == "missing" {
    foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
        replace `var' = . if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9
    }
    replace pentag = . if pentag_diss == 6 | pentag_diss == 7
    display "Disability codes recoded to MISSING"
}
else {
    foreach var in pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat street store address nod point {
        replace `var' = 0 if `var' == 6 | `var' == 7 | `var' == 8 | `var' == 9
    }
    replace pentag = 0 if pentag_diss == 6 | pentag_diss == 7
    display "Disability codes recoded to ZERO"
}

* Informant items: recode 2 to 0
recode street (2 = 0)
recode store (2 = 0)
recode address (2 = 0)

* Pentagon: ensure binary
replace pentag = 1 if pentag == 2

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
* COUNT VARIABLE (sum of 28 binary cognitive items)
*-------------------------------------------------------------------------------

egen count = rowtotal(pencil watch chair shoes knuckle elbow should bridge hammer pray chemist repeat town chief street store address longmem month day year season nod point circle pentag)

display "Count variable created (max should be 28):"
summarize count

*-------------------------------------------------------------------------------
* IMMEDIATE RECALL TOTAL (for potential imputation)
*-------------------------------------------------------------------------------

gen immed = cond(missing(learn1),0,learn1) + cond(missing(learn2),0,learn2) + cond(missing(learn3),0,learn3)

display "STEP 1 complete: Cognitive components prepared."
display "--------------------------------------------------------------------------------"
