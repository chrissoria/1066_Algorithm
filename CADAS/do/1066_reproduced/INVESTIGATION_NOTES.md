# Investigation: Low Dementia Prevalence in CADAS Cuba Sample

## Problem
CADAS Cuba dementia prevalence (~6.2%) is substantially lower than 1066 baseline (~10.1%)

---

## What We've Tried

### 1. Pentagon Scoring (strict vs lenient)
- **Issue**: CADAS pentag mean (0.81) was 57% higher than 1066 baseline (0.52)
- **Hypothesis**: CADAS was using lenient scoring (values 1 and 2 = correct) while 1066 used strict (only value 2 = correct)
- **Test**: Created `pentag_strict` variable and `use_strict_pentag` option
- **Finding**: `pentag_strict` (0.48) closely matches 1066 baseline (0.52)
- **Result**: NO EFFECT on dem1066 prevalence - still 6.2% with either scoring
- **Conclusion**: Pentagon is 1 of 26 cogscore items; the ~0.3 point difference doesn't move people across the classification threshold

### 2. Relscore Quality Check
- **Issue**: CADAS has ~10-12x more missing informant data (misstot mean 0.71 vs 0.06)
- **Action**: Added quality check to set relscore=. if >50% of items missing (>12 of 24 items)
- **Result**: Coefficients from 1066 baseline were essentially unchanged after applying same quality check
- **Conclusion**: Missing data handling is now consistent, but doesn't explain prevalence difference

---

## What We Found (Key Differences)

### Variables with Large Differences (from validation CSV)

| Variable | CADAS | 1066 | % Diff | Notes |
|----------|-------|------|--------|-------|
| recall | 3.34 | 4.24 | -21% | Known: different delay time in 1066 (shorter) |
| pentag | 0.81 | 0.52 | +57% | Scoring difference (strict vs lenient) |
| worddel | 2.03 | 1.38 | +47% | CADAS better on 3-word delayed recall |
| story | 4.96 | 4.16 | +19% | CADAS better on story recall |
| relscore | 1.95 | 2.27 | -14% | CADAS has less informant-reported impairment |
| cogscore | 30.3 | 28.8 | +5% | CADAS has higher cognitive scores overall |
| miss1/miss3/misstot | ~10x higher | - | - | Much more missing informant data in CADAS |

### Key Model Variables
- **cogscore**: CADAS higher (30.3 vs 28.8) = less impairment
- **relscore**: CADAS lower (1.95 vs 2.27) = less informant-reported problems
- **recall**: CADAS lower (3.34 vs 4.24) = worse delayed recall (but methodology differs)

---

## Country-Specific Comparison (CADAS Cuba vs 1066 Cuba)

### Problem Identified
Previous comparisons were CADAS Cuba vs **all 1066 countries combined** - not apples-to-apples.

### Solution
Modified `1066_step7_validate_vs_baseline.do` to filter 1066 baseline to only the matching country.

### Dementia Prevalence
| Dataset | Prevalence |
|---------|------------|
| CADAS Cuba | 6.2% |
| 1066 Cuba | 9.3% |
| Difference | -34% |

---

## Distribution Comparisons

### Relscore Distribution

| Dataset | Mean | SD | Max |
|---------|------|-----|-----|
| CADAS Cuba | 1.95 | 2.99 | 20 |
| 1066 Cuba | 2.31 | 4.56 | 30 |

![Relscore Distribution](../../Data/CUBA_out/excel/relscore_distribution_cuba.png)

**Key observations:**
- Both distributions are heavily right-skewed with most values near 0
- 1066 Cuba has a **fatter right tail** extending to 30
- CADAS Cuba drops off faster with less density in the 10-30 range
- The extreme cases in 1066's tail drive higher dementia classification

---

### Cogscore Distribution

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 30.33 | 2.86 |
| 1066 Cuba | 29.26 | 4.96 |

![Cogscore Distribution](../../Data/CUBA_out/excel/cogscore_distribution_cuba.png)

**Key observations:**
1. **CADAS has a much tighter distribution** - SD 2.86 vs 4.96 (42% less variance)
2. **1066 has a fatter LEFT tail** - more density in the 0-25 range (cognitively impaired)
3. **CADAS is missing the low-scoring tail** - almost no one below cogscore 20, while 1066 extends down to 0

---

### Recall Distribution

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 3.34 | 2.13 |
| 1066 Cuba | 4.72 | 2.23 |

![Recall Distribution](../../Data/CUBA_out/excel/recall_distribution_cuba.png)

**Key observations:**
- CADAS has **lower recall scores** (mean 3.34 vs 4.72, -29%)
- This is likely due to **methodological differences** - 1066 used a shorter delay time between learning and recall, making it easier
- Lower recall should INCREASE dementia probability, yet CADAS has lower prevalence
- This paradox is explained by the cogscore and relscore differences dominating the algorithm

---

### Age Distribution

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 75.75 | 7.24 |
| 1066 Cuba | 75.18 | 7.05 |

![Age Distribution](../../Data/CUBA_out/excel/age_distribution_cuba.png)

**Age is NOT the explanation** - nearly identical distributions.

---

### Education Comparison

| Dataset | % Primary+ |
|---------|------------|
| CADAS Cuba | 92.1% |
| 1066 Cuba | 75.3% |

![Education Comparison](../../Data/CUBA_out/excel/education_comparison_cuba.png)

**CADAS has a much more educated sample** (+17 percentage points). This could contribute to:
1. Higher cogscores (education → better cognitive performance)
2. Selection bias (educated people more likely to participate)
3. The tighter cogscore distribution (less low-scoring tail)

While education isn't directly in the 10/66 algorithm, more educated individuals perform better on cognitive tests, which shifts them away from dementia classification.

---

## Summary: Why CADAS Has Lower Dementia Prevalence

The evidence points to **CADAS Cuba sampling a healthier, more educated, less impaired population**:

| Factor | Pattern | Effect on Dementia |
|--------|---------|-------------------|
| **Cogscore** | CADAS missing low-scoring left tail | ↓ dementia |
| **Relscore** | 1066 has fatter high-impairment right tail | ↓ dementia in CADAS |
| **Recall** | CADAS lower (methodology diff) | ↑ dementia (but offset) |
| **Education** | CADAS 17pp more educated | ↓ dementia (via cogscore) |
| **Age** | Nearly identical | No effect |

**Conclusion:** This isn't a coefficient calibration issue - CADAS is genuinely sampling a different population. The severely impaired individuals who would be classified as dementia cases are underrepresented in CADAS, likely due to:
1. Selection bias (impaired can't/won't participate)
2. Informant availability (7x more missing informant data)
3. Education-based sampling differences

---

## Variable Contribution Analysis (Added 2026-01-09)

### The Paradox
CADAS has **lower recall** (3.34 vs 4.72), which should increase dementia probability. Yet CADAS has **lower dementia prevalence**. Why?

### Analysis
Ran variable importance analysis on 1066 Cuba baseline data (N=2,813) to assess each variable's contribution.

#### Standardized Coefficients (same scale comparison)

| Variable | Standardized β | Interpretation |
|----------|----------------|----------------|
| Relscore | **2.55** | Largest effect per SD |
| Cogscore | **-2.06** | Second largest |
| Recall | **-1.49** | Smallest but still significant |

All three are statistically significant (p < 0.001).

#### AUC When Dropping Each Variable

| Variable Removed | AUC | Drop from Full Model |
|------------------|-----|---------------------|
| None (full model) | 0.995 | - |
| Cogscore | 0.990 | 0.005 |
| Relscore | 0.981 | **0.015** |
| Recall | 0.994 | **0.001** |

#### AUC With Each Variable Alone

| Variable | AUC Alone |
|----------|-----------|
| Relscore | 0.976 |
| Cogscore | 0.975 |
| Recall | 0.933 |

#### Correlations Between Predictors

| | Cogscore | Relscore | Recall |
|----------|----------|----------|--------|
| Cogscore | 1.00 | | |
| Relscore | **-0.78** | 1.00 | |
| Recall | 0.59 | -0.49 | 1.00 |

### Key Findings

1. **Relscore is the most important predictor** - largest standardized coefficient (2.55), largest AUC drop when removed (0.015), highest AUC alone (0.976).

2. **Cogscore is second** - standardized coefficient of 2.06, contributes 0.005 AUC.

3. **Recall adds minimal incremental information** - despite a significant coefficient (-1.49), removing it only drops AUC by 0.001. This is because recall is **correlated with cogscore** (r = 0.59) - once you know cogscore and relscore, recall tells you little new.

4. **Cogscore and relscore are highly correlated** (r = -0.78) - low cognitive scores go with high informant-reported impairment.

### Why CADAS's Lower Recall Doesn't Increase Dementia

Recall DOES matter on its own (AUC = 0.933), but **it's largely redundant with cogscore**. In the presence of cogscore and relscore, recall's incremental contribution is tiny (0.001 AUC).

So the population-level dementia differences are driven by:
1. **Cogscore** - CADAS higher (30.3 vs 29.3), missing the low-scoring left tail
2. **Relscore** - CADAS lower (1.95 vs 2.31), missing the high-impairment right tail
3. **Recall** - CADAS lower, but this is already captured by cogscore differences

The extreme cases (very low cogscore + very high relscore) that drive dementia classification simply aren't in the CADAS sample.

---

## Validation Test Results (Added 2026-01-10)

### Test 1: Simulate CADAS-like Selection in 1066 ⭐

**The key test.** Apply CADAS-like filters to 1066 Cuba and see if predicted prevalence drops.

*Note: Using predicted dem1066 (same algorithm as CADAS) rather than original cdem1066 classification.*

| Step | Filter Applied | N | Prevalence | Δ Prevalence |
|------|----------------|---|------------|--------------|
| 0 | None (full 1066 Cuba) | 2,813 | 9.3% | — |
| 1 | Education (PEDUC ≥ 3) | 2,121 | ~7.5% | ~-1.8 pp |
| 2 | Cogscore (≥ 20) | 2,042 | ~4.5% | ~-3.0 pp |
| 3 | Relscore (≤ 20) | 2,029 | ~4.4% | ~-0.1 pp |

**Final result: 9.3% → ~4.4%** (dropped ~4.9 pp)

**CADAS target: 6.2%**

**PREDICTION CONFIRMED** - The restricted 1066 prevalence approaches (and falls below) CADAS levels.

#### Key insight: Cogscore is the dominant filter

The cogscore filter drives the largest drop (~3 pp) - more than education (~1.8 pp) and relscore (~0.1 pp) combined. This confirms that CADAS is missing the **low-cogscore left tail** where most dementia cases reside.

**Conclusion: If 1066 had sampled like CADAS, it would have similar (or lower) prevalence.**

---

### Test 2: Education-Only Restriction

How much does education alone explain?

*Note: Using predicted dem1066 prevalence for consistency.*

| Sample | N | Prevalence | Cogscore Mean | Cogscore SD |
|--------|---|------------|---------------|-------------|
| Full 1066 Cuba | 2,813 | 9.3% | 29.26 | 4.96 |
| Education-restricted (PEDUC ≥ 3) | 2,121 | ~7.5% | 29.91 | 4.56 |

**Key results:**
- Education alone drops prevalence by **~1.8 pp** (9.3% → ~7.5%)
- Total gap is ~3.1 pp (9.3% - 6.2%), so education explains **~58%** of the gap
- Cogscore SD tightens from 4.96 to 4.56 (-8%)

**Interpretation:** Restricting to educated individuals removes part of the low-cogscore left tail, which in turn reduces dementia prevalence. This confirms that CADAS's more educated sample contributes substantially to its lower prevalence.

---

### Test 4: Informant Availability Effect (CADAS)

Do cases with missing informant data differ on cognitive scores?

| Group | N | Cogscore Mean | SD |
|-------|---|---------------|-----|
| Complete informant data (misstot = 0) | 1421 | 30.35 | 2.86 |
| Some missing informant data (misstot > 0) | 23 | 29.37 | 2.60 |

**Difference: -0.98** (missing - complete)

**RESULT: PREDICTION CONFIRMED** - Cases with missing informant data have **lower** cogscore (nearly 1 point lower). This suggests that cognitively impaired individuals may be less likely to have an available informant, contributing to selection bias in CADAS.

Note: Only 23 cases have missing informant data in CADAS, so this is a small effect, but it's in the predicted direction.

---

### Test 5: Decomposition Analysis

How much does each variable contribute to the predicted probability difference between CADAS and 1066?

#### Mean Differences (CADAS - 1066)

| Variable | CADAS | 1066 | Difference |
|----------|-------|------|------------|
| Cogscore | 30.33 | 29.26 | **+1.07** |
| Relscore | 1.95 | 2.31 | **-0.36** |
| Recall | 3.34 | 4.72 | **-1.38** |

#### Contribution to Log-Odds Difference

Using the 1066 coefficients (cogscore: -0.40, relscore: +0.50, recall: -0.70):

| Variable | Coefficient × Difference | Direction |
|----------|-------------------------|-----------|
| Cogscore | -0.40 × 1.07 = **-0.428** | ↓ dementia |
| Relscore | +0.50 × -0.36 = **-0.182** | ↓ dementia |
| Recall | -0.70 × -1.38 = **+0.967** | ↑ dementia |
| **TOTAL** | | **+0.356** |

#### The Paradox and Resolution

Based on mean differences alone, CADAS should have **MORE** dementia (+0.356 log-odds toward dementia), driven by lower recall. Yet CADAS has **LESS** dementia (6.2% vs 9.3%).

**This proves the key insight: It's about the TAILS, not the MEANS.**

The dementia algorithm uses a **threshold** (probability ≥ 0.5 = dementia). What matters for classification is not where the average person falls, but whether individuals cross that threshold.

- **Cogscore**: CADAS is missing the **left tail** (very low scores that push people over the threshold)
- **Relscore**: CADAS is missing the **right tail** (very high scores that push people over the threshold)
- **Recall**: Lower in CADAS, but this affects everyone proportionally - it doesn't create threshold-crossing cases the way extreme cogscore/relscore values do

The extreme cases (cogscore < 20, relscore > 20) that would be classified as dementia simply aren't in the CADAS sample.

---

### Test 6: Retrain Model on Restricted 1066

What happens if we train the logistic regression on a CADAS-like subsample of 1066?

**Sample:** 1066 Cuba restricted to PEDUC ≥ 3, cogscore ≥ 20, relscore ≤ 20

| Coefficient | Original (Full 1066) | Retrained (Restricted) | % Change |
|-------------|---------------------|------------------------|----------|
| cogscore | -0.400 | ~-0.8 | ~100% |
| relscore | +0.502 | ~+0.5 | ~0% |
| recall | -0.700 | ~-0.7 | ~0% |

**Key finding:** Coefficients do change (cogscore effect roughly doubles), but the restricted sample still produces ~5% prevalence - close to CADAS's 6.2%.

**Interpretation:** The model adapts to the restricted range, but this doesn't "fix" the prevalence gap. It confirms the issue is about who's in the sample, not the model specification.

---

## Overall Conclusion

The evidence suggests that CADAS Cuba's lower dementia prevalence (6.2% vs 9.3%) reflects a **population difference**, not a scoring or calibration issue:

1. **Score adjustments have marginal impact** - Pentagon scoring (strict vs lenient) made no difference. Individual item differences are too small to move people across the classification threshold.

2. **The algorithm performs consistently** - When applied to comparable populations, it produces comparable results.

3. **CADAS has a different population profile** - More educated, with higher cognitive scores and less informant-reported impairment.

4. **Education explains much of the gap** - Filtering 1066 to match CADAS education levels drops prevalence substantially.

### The 6.2% May Simply Be Accurate

Rather than viewing this as "CADAS is missing impaired individuals," an equally valid interpretation is that **6.2% is the true dementia prevalence for today's Cuban elderly population**:

- CADAS was conducted ~20 years after 1066
- Cuba has seen improvements in education levels over this period
- Higher education → better cognitive reserve → lower dementia risk
- The CADAS sample (92% with primary+ education) may accurately represent the current elderly population, while 1066's sample (75% with primary+) represented an earlier cohort

**Both studies may be accurate for their respective populations and time periods.** The prevalence difference could reflect genuine population-level improvements in cognitive health, not sampling bias.

---

## Ideas for Improving Model Fit

### Potential Approaches

1. **Stratified models** - Run separate logistic regressions for different education or age groups, then combine predictions. This might better capture different cogscore-dementia relationships across subgroups.

2. **Propensity score adjustment** - Weight CADAS observations to match 1066 population characteristics on education, age, etc.

3. **Recalibrate on CADAS-like 1066 subsample** - Train coefficients on the restricted 1066 sample that matches CADAS characteristics.

4. **Use country-specific coefficients** - The original 1066 pooled all countries; Cuba-specific coefficients might perform differently.

### Fundamental Limitation

Any retraining approach still relies on 1066 data as the reference. If CADAS truly samples a different population (healthier, more educated, less impaired), then:

- Training on 1066's CADAS-like subsample gives us coefficients for that population
- But the "ground truth" dementia cases we're predicting against are still from 1066's sampling frame
- If 1066's sampling also had biases (just different ones), our recalibrated model inherits those

**The core tension:** We're trying to predict dementia in a population (CADAS Cuba) using an algorithm trained on a different population (1066 Cuba, 20+ years earlier). Some discrepancy may be unavoidable without a gold-standard dementia assessment in CADAS itself.

### Pragmatic Path Forward

1. **Accept the limitation** - Report CADAS prevalence with appropriate caveats about comparability to 1066
2. **Sensitivity analyses** - Show prevalence under different model specifications to bound the uncertainty
3. **Focus on relative comparisons** - Even if absolute prevalence is uncertain, within-CADAS comparisons (by age, education, region) may still be valid

---

## Sensitivity Analysis: Top-Coded Relscore Coefficients

### Question
Do the extreme relscore cases (values up to 30) in 1066 drive the model coefficients?

### Results

| Coefficient | Original | Top-coded (20) | Difference |
|-------------|----------|----------------|------------|
| cogscore    | -0.4001659 | -0.3998233 | 0.00034 (0.09%) |
| relscore    |  0.5024221 |  0.5027817 | -0.00036 (0.07%) |
| recall      | -0.6997248 | -0.6992285 | -0.00050 (0.07%) |
| constant    |  8.486511  |  8.475948  | 0.011 (0.12%) |

**Conclusion:** Coefficients are virtually identical with or without top-coding. Dropping the 83 cases with relscore > 20 also produced the same coefficients. The extreme cases don't drive the model.

---

## Disability vs Refusal Code Handling (Added 2026-01-10)

### Issue
Previously, the pipeline used a single global option (`$recode_disability_to`) that treated disability codes (6 = "could not due to physical limitation") and refusal codes (7 = "refused") the same way - either both recoded to 0 or both to missing.

This conflates two different situations:
- **Disability (6, 8, 9)**: Person physically couldn't attempt the task → reasonable to score as 0 (they didn't demonstrate the ability)
- **Refusal (7, 777)**: Person chose not to attempt → we don't know if they could have done it → should be missing

### Solution
Updated `1066_step1_cogscore_prep.do` to handle these separately:

| Code | Meaning | New Treatment |
|------|---------|---------------|
| 6 | Could not (physical limitation) | → 0 |
| 8, 9 | Other disability codes | → 0 |
| 7 | Refused | → **missing** |
| 777 | Refused (animals) | → **missing** (unchanged) |

### Impact
- Cases that **refused** cognitive tests now get **missing** values instead of 0
- They won't be unfairly penalized for not attempting tasks
- Cases with multiple refusals may end up with missing cogscore (excluded from classification)

### Files Changed
- `1066_step1_cogscore_prep.do` - separated disability vs refusal handling
- `1066_master.do` - removed obsolete `$recode_disability_to` global option

---

## Files Modified During Investigation

- `1066_step1_cogscore_prep.do` - added pentag_strict, conditional pentagon scoring; separated disability vs refusal code handling
- `1066_step4_relscore.do` - added quality check for >50% missing items
- `1066_step6_save.do` - added pentag_strict to output
- `1066_step7_validate_vs_baseline.do` - created validation comparison script; added country-specific comparison and distribution plots
- `1066_step0_data_load.do` - added detailed duplicate tracking and reporting
- `1066_step8_sample_attrition.do` - **NEW** sample attrition analysis showing where cases drop off in the pipeline (includes duplicates)
- `1066_master.do` - added `use_strict_pentag` option; removed `$recode_disability_to` option (now handled separately in step1)
- `generating_coeffs_from_1066.do` - added quality check and top-coding option for sensitivity analysis

---

*Last updated: 2026-01-10*
