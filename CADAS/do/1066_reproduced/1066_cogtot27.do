********************************************************************************
* COGTOT27: HRS-style TICS cog27 reproduction for CADAS
*
* Builds the Health and Retirement Study TICS composite (0-27) using
* CADAS cognitive items. CADAS has direct analogs for all four HRS components.
*
* HRS reference (validated r=0.997 vs RAND harmonized measure, 2020):
*   cog27 = imrc + dlrc + ser7 + bwc20
*     imrc  : immediate 10-word recall, single trial (0-10)
*     dlrc  : delayed 10-word recall (0-10)
*     ser7  : serial 7s, chained subtraction from 100 (0-5)
*     bwc20 : backward count from 20 (0-2)
*
* CADAS mappings:
*   imrc_h  <- learn1            (CERAD trial 1, 0-10)
*   dlrc_h  <- recall            (CERAD delayed, 0-10)
*   ser7_h  <- serial7_score     (built in Cog_Read.do, same chained logic)
*   bwc20_h <- c_45 (first attempt) + c_46 (second attempt)
*             Q45 asks respondent to count backward 20->11 (or 19->10).
*             c_45 values (encoded in Cog_Read.do):
*                1 = correcto       (first try correct -> bwc20 = 2)
*                2 = quiere empezar de nuevo (second attempt -> check c_46)
*                0 = incorrecto     (failed, no retry -> bwc20 = 0)
*                7 = rehusa         (refused -> missing)
*             c_46 (second attempt) values:
*                1 = correcto       (second try correct -> bwc20 = 1)
*                0 = incorrecto     (-> bwc20 = 0)
*                7 = rehusa         (-> missing)
*
* Outputs (saved to cog_algorithms.dta):
*   cogtot27          = imrc + dlrc + ser7 + bwc20  (0-27; HRS-equivalent)
*   cogtot27_cat      = Langa-Weir categorical (Crimmins 2011):
*                         0 = normal     (12-27)
*                         1 = CIND       (7-11)
*                         2 = dementia   (0-6)
*   cogtot27_dem      = binary dementia indicator (cogtot27 <= 6)
*
* Run after 1066_step6_save.do. Reads cog_algorithms.dta, merges needed vars from
* cog_merged.dta (NOT cog.dta -- the latter drops serial7_score post-scoring),
* adds new columns, saves back to cog_algorithms.dta.
*
*-------------------------------------------------------------------------------
* CROSS-CULTURAL VALIDITY CAVEAT (important for CADAS interpretation)
*-------------------------------------------------------------------------------
* The Langa-Weir / Crimmins (2011) cutoffs (0-6 = dementia, 7-11 = CIND,
* 12-27 = normal) were derived in the ADAMS substudy of HRS: ~856 US older
* adults with both TICS-27 and a full neuropsychological consensus diagnosis.
* Those thresholds maximize agreement with DSM-IV consensus diagnosis in THAT
* US, English-speaking, ~12-year-median-education sample.
*
* In CADAS (DR/Cuba/PR), the cutoffs do NOT carry the same calibration:
*   1. EDUCATION. TICS-27 is not education-adjusted. Serial 7s and 10-word
*      recall track schooling/numeracy independent of cognitive pathology.
*      CADAS samples have lower mean formal education than ADAMS, so raw
*      scores are depressed for non-pathological reasons. Result: the cutoff
*      over-classifies dementia in CADAS.
*   2. TRANSLATION. The Spanish CERAD word list differs from English in
*      concreteness, frequency, and phonology, so recall difficulty isn't
*      identical. Backward count from 20 is largely culture-free; serial 7s
*      is partly numeracy.
*   3. REFERENCE STANDARD. ADAMS used DSM-IV; 10/66's dem1066 uses a
*      separately calibrated clinician + informant standard developed in
*      LMICs (including DR). The two are overlapping but non-identical
*      constructs.
*   4. BASE RATE / CASE MIX. ADAMS oversampled cognitively impaired cases to
*      fit the cutoff; CADAS is community-based with a different prevalence
*      and severity distribution.
*
* Empirical signal (DR, Jun 2026 run, N=1,534):
*   mean(cogtot27_dem) = 0.268 (26.8% Langa-Weir dementia)
*   mean(dem1066)      = 0.189 (18.9% 10/66 dementia)
* Both rates are higher than community-dwelling 65+ dementia prevalence
* worldwide (~5-15%). Langa-Weir is the more over-positive of the two; the
* methods agree strongly at the extremes (~97% concordance on Normal tail)
* and diverge in the middle range.
*
* GUIDANCE
*   - For cross-study comparisons, prefer the continuous cogtot27 score over
*     the dichotomized cogtot27_dem -- the continuous score does not carry
*     the cutoff's calibration assumptions.
*   - For dementia classification in CADAS, dem1066 is the better choice:
*     it was validated in Latin American settings, including DR (Prince et
*     al. 2003, 2007).
*   - If reporting cogtot27_dem, label it "Langa-Weir-classified" rather
*     than "dementia," and report it alongside dem1066 so the discordance
*     is visible.
*   - For education-adjusted alternatives, see Wu et al. (2014) and the
*     Langa-Weir 2020 update; for country-specific cutoffs, the Mexican
*     HRS (ENASEM) literature uses 5/6 rather than 6/7.
********************************************************************************

display _newline(1)
display "================================================================================"
display "BUILDING HRS-style cogtot27"
display "================================================================================"

use "$data_path/cog_algorithms.dta", clear

*-------------------------------------------------------------------------------
* MERGE serial7_score, c_45, c_46 FROM cog_merged.dta
* cog.dta drops these post-scoring; cog_merged.dta retains them.
*-------------------------------------------------------------------------------

preserve
    use "$data_path/cog_merged.dta", clear
    bysort pid: keep if _n == 1
    keep pid serial7_score c_45 c_46
    tempfile cog_extras
    save `cog_extras', replace
restore

merge 1:1 pid using `cog_extras', keep(master match) nogen

*-------------------------------------------------------------------------------
* COMPONENT 1: imrc_h - immediate 10-word recall (0-10)
* HRS uses one trial of 10 CERAD words; CADAS gave three (learn1/2/3).
* learn1 is the strictest analog (first trial only).
*-------------------------------------------------------------------------------

gen imrc_h = learn1
label variable imrc_h "HRS-style imrc: CADAS learn1 (CERAD trial 1, 0-10)"

*-------------------------------------------------------------------------------
* COMPONENT 2: dlrc_h - delayed 10-word recall (0-10)
*-------------------------------------------------------------------------------

gen dlrc_h = recall
label variable dlrc_h "HRS-style dlrc: CADAS recall (CERAD delayed, 0-10)"

*-------------------------------------------------------------------------------
* COMPONENT 3: ser7_h - serial 7s (0-5)
*-------------------------------------------------------------------------------

gen ser7_h = serial7_score
replace ser7_h = . if ser7_h == .i | ser7_h == .v
label variable ser7_h "HRS-style ser7: CADAS serial7_score (chained, 0-5)"

*-------------------------------------------------------------------------------
* COMPONENT 4: bwc20_h - backward count from 20 (0-2)
* Direct HRS-style scoring from c_45 / c_46:
*   2 if first attempt correct (c_45 == 1)
*   1 if second attempt correct (c_45 == 2 & c_46 == 1)
*   0 if incorrect on either attempt
*   missing if refused or never administered
*-------------------------------------------------------------------------------

gen bwc20_h = .
replace bwc20_h = 2 if c_45 == 1
replace bwc20_h = 1 if c_45 == 2 & c_46 == 1
replace bwc20_h = 0 if c_45 == 0
replace bwc20_h = 0 if c_45 == 2 & c_46 == 0
* c_45 == 7 (refused) or .i/.v -> remain missing
* c_45 == 2 & c_46 == 7 (refused on retry) -> remain missing
label variable bwc20_h "HRS-style bwc20: backward count from 20 (0-2, from c_45/c_46)"

*-------------------------------------------------------------------------------
* COMPOSITE
*-------------------------------------------------------------------------------

gen cogtot27 = imrc_h + dlrc_h + ser7_h + bwc20_h
label variable cogtot27 "HRS-style cog27: imrc+dlrc+ser7+bwc20 (0-27)"

*-------------------------------------------------------------------------------
* LANGA-WEIR CLASSIFICATION (Crimmins et al. 2011)
*   0-6   = dementia
*   7-11  = CIND (cognitive impairment, no dementia)
*   12-27 = normal
*-------------------------------------------------------------------------------

gen cogtot27_cat = .
replace cogtot27_cat = 0 if cogtot27 >= 12 & cogtot27 <= 27
replace cogtot27_cat = 1 if cogtot27 >= 7  & cogtot27 <= 11
replace cogtot27_cat = 2 if cogtot27 >= 0  & cogtot27 <= 6
label define lw_cat 0 "Normal (12-27)" 1 "CIND (7-11)" 2 "Dementia (0-6)"
label values cogtot27_cat lw_cat
label variable cogtot27_cat "Langa-Weir category from cogtot27 (Crimmins 2011)"

gen cogtot27_dem = .
replace cogtot27_dem = 1 if cogtot27 >= 0 & cogtot27 <= 6
replace cogtot27_dem = 0 if cogtot27 >= 7 & cogtot27 <= 27
label variable cogtot27_dem "Dementia indicator (cogtot27 <= 6, Langa-Weir)"

*-------------------------------------------------------------------------------
* DIAGNOSTICS
*-------------------------------------------------------------------------------

display _newline(1)
display "--- COMPONENT SUMMARIES ---"
summarize imrc_h dlrc_h ser7_h bwc20_h cogtot27

display _newline(1)
display "--- COMPONENT MISSINGNESS ---"
foreach v in imrc_h dlrc_h ser7_h bwc20_h cogtot27 {
    quietly count if missing(`v')
    local n = r(N)
    display "  `v': `n' missing"
}

display _newline(1)
display "--- c_45 / c_46 -> bwc20_h crosswalk ---"
tab c_45 bwc20_h, miss
display ""
tab c_46 bwc20_h if c_45 == 2, miss

display _newline(1)
display "--- LANGA-WEIR CLASSIFICATION ---"
tab cogtot27_cat, miss
display ""
tab cogtot27_dem, miss

*-------------------------------------------------------------------------------
* SAVE BACK TO cog_algorithms.dta
*-------------------------------------------------------------------------------

save "$data_path/cog_algorithms.dta", replace

display _newline(1)
display "cogtot27 step complete. Variables added to cog_algorithms.dta:"
display "  imrc_h, dlrc_h, ser7_h, bwc20_h, cogtot27, cogtot27_cat, cogtot27_dem"
display "================================================================================"
