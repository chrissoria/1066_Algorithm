# Investigation: Low Dementia Prevalence in CADAS Cuba Sample

## Problem
CADAS Cuba dementia prevalence (~6.2%) is substantially lower than 1066 baseline (~10.1%)

---

## What We've Tried

| Approach | What We Did | Result |
|----------|-------------|--------|
| **Pentagon scoring** | Tested strict (only 2 = correct) vs lenient (1 or 2 = correct) scoring | No effect—pentagon is 1 of 26 cogscore items, too small to matter |
| **Relscore quality check** | Set relscore to missing if >50% of informant items missing | No effect—coefficients unchanged, doesn't explain gap |
| **Country-specific comparison** | Compared CADAS Cuba to 1066 Cuba (not all countries) | Gap persists: 6.2% vs 9.3% |

**Bottom line:** Scoring adjustments and data quality fixes don't explain the prevalence difference. The issue is who's in the sample, not how we're scoring them.

---

## Where does CADAS differ from 1066 on key variables?

| Variable | CADAS | 1066 | Difference | Interpretation |
|----------|-------|------|------------|----------------|
| **cogscore** | 30.3 | 28.8 | +5% | CADAS has higher cognitive scores |
| **relscore** | 1.95 | 2.27 | -14% | CADAS has less informant-reported impairment |
| **recall** | 3.34 | 4.24 | -21% | CADAS lower (but 1066 used shorter delay) |
| worddel | 2.03 | 1.38 | +47% | CADAS better on 3-word delayed recall |
| story | 4.96 | 4.16 | +19% | CADAS better on story recall |
| pentag | 0.81 | 0.52 | +57% | Scoring difference (strict vs lenient) |
| misstot | 0.71 | 0.06 | ~10x | Much more missing informant data in CADAS |

**What this means:** CADAS participants have higher cognitive scores and less informant-reported impairment—both pointing toward a healthier sample. The lower recall in CADAS is likely a methodological artifact (longer delay between learning and recall).

---

## How do the CADAS and 1066 Cuba sample distributions compare?

Previous comparisons used all 1066 countries combined. Here we compare CADAS Cuba to 1066 Cuba only.

| Dataset | Dementia Prevalence |
|---------|---------------------|
| CADAS Cuba | 6.2% |
| 1066 Cuba | 9.3% |

The following distribution comparisons reveal *why* the samples produce different prevalence rates.

---

### Does CADAS have less informant-reported impairment?

| Dataset | Mean | SD | Max |
|---------|------|-----|-----|
| CADAS Cuba | 1.95 | 2.99 | 20 |
| 1066 Cuba | 2.31 | 4.56 | 30 |

![Relscore Distribution](../../Data/CUBA_out/plots/relscore_distribution_cuba.png)

**Result:** Yes. Both distributions are right-skewed, but 1066 has a fatter tail extending to 30. Nobody in CADAS has a relscore above 20—the high-impairment cases that drive dementia classification simply aren't there.

---

### Does CADAS have higher cognitive scores?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 30.33 | 2.86 |
| 1066 Cuba | 29.26 | 4.96 |

![Cogscore Distribution](../../Data/CUBA_out/plots/cogscore_distribution_cuba.png)

**Result:** Yes, and with much less variance. CADAS has 42% less spread (SD 2.86 vs 4.96). Critically, CADAS is missing the low-scoring left tail—almost no one scores below 20, while 1066 extends down to 0. This is where dementia cases live.

---

### Does CADAS have different recall scores?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 3.34 | 2.13 |
| 1066 Cuba | 4.72 | 2.23 |

![Recall Distribution](../../Data/CUBA_out/plots/recall_distribution_cuba.png)

**Result:** CADAS has *lower* recall (3.34 vs 4.72), which should increase dementia probability. But this is a methodological artifact: 1066 used a shorter delay between learning and recall, making it easier. The cogscore and relscore differences dominate, offsetting this effect.

---

### Does age explain the difference?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS Cuba | 75.75 | 7.24 |
| 1066 Cuba | 75.18 | 7.05 |

![Age Distribution](../../Data/CUBA_out/plots/age_distribution_cuba.png)

**Result:** No. Age distributions are nearly identical.

---

### Does education explain the difference?

| Dataset | % Primary+ |
|---------|------------|
| CADAS Cuba | 92.1% |
| 1066 Cuba | 75.3% |

![Education Comparison](../../Data/CUBA_out/plots/education_comparison_cuba.png)

**Result:** Partially. CADAS has a much more educated sample (+17 percentage points). Education isn't directly in the algorithm, but more educated people perform better on cognitive tests, which shifts them away from dementia classification. This likely contributes to CADAS's tighter cogscore distribution and missing low-scoring tail.

---

## Hypotheses to Test

The distribution comparisons suggest CADAS Cuba is sampling a healthier, more educated, less impaired population. If true, the following hypotheses should hold:

| Hypothesis | Prediction |
|------------|------------|
| **Recall is redundant** | Recall should add minimal predictive value beyond cogscore and relscore, explaining why CADAS's lower recall doesn't increase dementia |
| **Selection bias** | If we filter 1066 to match CADAS characteristics (education, cogscore range, relscore range), prevalence should drop toward 6.2% |
| **Education effect** | Restricting 1066 to educated individuals should reduce prevalence and tighten the cogscore distribution |
| **Informant availability** | Cases with missing informant data should have lower cognitive scores (impaired individuals less likely to have informants) |
| **Tails matter more than means** | The prevalence gap is driven by missing extreme cases, not by differences in average scores |
| **Model stability** | Retraining the model on a CADAS-like subsample shouldn't "fix" the gap, confirming this is a sampling issue, not a calibration issue |

The following sections test these hypotheses.

---

## Why doesn't CADAS's lower recall lead to higher dementia prevalence?

*Tests the "Recall is redundant" hypothesis.*

CADAS has lower recall scores (3.34 vs 4.72), which should increase dementia probability. Yet CADAS has lower dementia prevalence. This section analyzes which variables actually drive the algorithm.

### Which variables matter most?

Variable importance analysis on 1066 Cuba baseline (N=2,813):

**Standardized coefficients:**

| Variable | Standardized β | Interpretation |
|----------|----------------|----------------|
| Relscore | **2.55** | Largest effect per SD |
| Cogscore | **-2.06** | Second largest |
| Recall | **-1.49** | Smallest but still significant |

**AUC when dropping each variable:**

| Variable Removed | AUC | Drop from Full Model |
|------------------|-----|---------------------|
| None (full model) | 0.995 | - |
| Cogscore | 0.990 | 0.005 |
| Relscore | 0.981 | 0.015 |
| Recall | 0.994 | 0.001 |

**AUC with each variable alone:**

| Variable | AUC Alone |
|----------|-----------|
| Relscore | 0.976 |
| Cogscore | 0.975 |
| Recall | 0.933 |

**Correlations between predictors:**

| | Cogscore | Relscore | Recall |
|----------|----------|----------|--------|
| Cogscore | 1.00 | | |
| Relscore | -0.78 | 1.00 | |
| Recall | 0.59 | -0.49 | 1.00 |

### What this means

1. **Relscore is the most important predictor**: largest standardized coefficient, largest AUC drop when removed, highest AUC alone.

2. **Cogscore is second**: standardized coefficient of 2.06, contributes 0.005 AUC.

3. **Recall adds minimal incremental information**: removing it only drops AUC by 0.001. Recall is correlated with cogscore (r = 0.59), so once you know cogscore and relscore, recall tells you little new.

4. **Cogscore and relscore are highly correlated** (r = -0.78): low cognitive scores go with high informant-reported impairment.

### Result: Hypothesis confirmed

Recall matters on its own (AUC = 0.933), but it's largely redundant with cogscore. In the presence of cogscore and relscore, recall's incremental contribution is tiny (0.001 AUC).

The prevalence difference is driven by:
- **Cogscore**: CADAS higher, missing the low-scoring left tail
- **Relscore**: CADAS lower, missing the high-impairment right tail
- **Recall**: CADAS lower, but this is already captured by cogscore differences

The extreme cases (very low cogscore + very high relscore) that drive dementia classification simply aren't in the CADAS sample.

---

## Validation Test Results (Added 2026-01-10)

### What happens if we apply CADAS-like filters to 1066? ⭐

This is the key test. If CADAS's lower prevalence is due to sampling a healthier population, then filtering 1066 to match CADAS characteristics should produce similar prevalence.

| Step | Filter Applied | N | Prevalence | Change |
|------|----------------|---|------------|--------|
| 0 | None (full 1066 Cuba) | 2,813 | 9.3% | — |
| 1 | Education (PEDUC ≥ 3) | 2,121 | ~7.5% | -1.8 pp |
| 2 | Cogscore (≥ 20) | 2,042 | ~4.5% | -3.0 pp |
| 3 | Relscore (≤ 20) | 2,029 | ~4.4% | -0.1 pp |

**Result:** 9.3% → 4.4% (CADAS is 6.2%)

**What this means:** When we restrict 1066 to match CADAS characteristics (primary education or higher, cogscore ≥ 20, relscore ≤ 20), prevalence drops to (and below) CADAS levels. The restricted prevalence (4.4%) falls slightly below CADAS (6.2%) because our education filter is stricter than reality: CADAS still has 8% without primary education. The cogscore filter has the largest effect (-3 pp), confirming that CADAS is missing the low-cogscore left tail where most dementia cases reside.

---

### How much does education alone explain?

| Sample | N | Prevalence | Cogscore Mean | Cogscore SD |
|--------|---|------------|---------------|-------------|
| Full 1066 Cuba | 2,813 | 9.3% | 29.26 | 4.96 |
| Education-restricted (PEDUC ≥ 3) | 2,121 | ~7.5% | 29.91 | 4.56 |

**Result:** Education alone drops prevalence by 1.8 pp (9.3% → 7.5%), explaining about 58% of the gap.

**What this means:** More educated individuals perform better on cognitive tests. Restricting 1066 to educated individuals removes part of the low-cogscore tail, which reduces dementia prevalence. This suggests CADAS's more educated sample (92% vs 75% with primary education) contributes substantially to its lower prevalence.

---

### Do cases with missing informant data have different cognitive scores?

| Group | N | Cogscore Mean | SD |
|-------|---|---------------|-----|
| Complete informant data (misstot = 0) | 1,421 | 30.35 | 2.86 |
| Some missing data (misstot > 0) | 23 | 29.37 | 2.60 |

**Result:** Cases with missing informant data score nearly 1 point lower on cogscore (-0.98).

**What this means:** Cognitively impaired individuals may be less likely to have an available informant, contributing to selection bias. However, only 23 cases have missing informant data in CADAS, so this is a small effect—the missing distribution tails are the bigger driver.

---

### Which variable contributes most to the prevalence difference?

**Mean differences (CADAS - 1066):**

| Variable | CADAS | 1066 | Difference | Effect on Dementia |
|----------|-------|------|------------|-------------------|
| Cogscore | 30.33 | 29.26 | +1.07 | ↓ dementia |
| Relscore | 1.95 | 2.31 | -0.36 | ↓ dementia |
| Recall | 3.34 | 4.72 | -1.38 | ↑ dementia |

CADAS has better average cogscore (higher) and better average relscore (lower), both of which reduce dementia probability. However, CADAS has worse average recall (lower), which increases dementia probability.

**The paradox:** When we multiply these differences by their coefficients, the recall effect (+0.97 log-odds toward dementia) outweighs the cogscore (-0.43) and relscore (-0.18) effects combined. Based on means alone, CADAS should have *more* dementia. Yet CADAS has *less* dementia.

**Resolution: It's about the tails, not the means.**

The algorithm classifies dementia using a threshold (probability ≥ 0.5). What matters isn't where the average person falls, but whether individuals cross that threshold. CADAS has tighter distributions with missing extremes:

- **Cogscore**: CADAS is missing the left tail (very low scores)
- **Relscore**: CADAS is missing the right tail (very high scores)
- **Recall**: Lower in CADAS, but affects everyone proportionally—doesn't create threshold-crossing cases

The extreme cases (cogscore < 20, relscore > 20) that would be classified as dementia simply aren't in the CADAS sample.

---

### What happens if we retrain the model on a CADAS-like sample?

Could the prevalence gap be a calibration issue? Maybe the original 1066 coefficients don't apply well to a more educated, healthier population like CADAS. If we retrain the model on a CADAS-like subset of 1066, would prevalence increase back toward 9.3%?

**Sample:** 1066 Cuba restricted to PEDUC ≥ 3, cogscore ≥ 20, relscore ≤ 20

| Coefficient | Original (full 1066) | Retrained (restricted) | % Change |
|-------------|----------------------|------------------------|----------|
| cogscore | -0.400 | ~-0.8 | ~100% |
| relscore | +0.502 | ~+0.5 | ~0% |
| recall | -0.700 | ~-0.7 | ~0% |

**Result:** The cogscore coefficient roughly doubles (the model adjusts to the narrower range), but the restricted sample still produces ~5% prevalence—close to CADAS's 6.2%, not back up to 9.3%.

**What this means:** Retraining the coefficients on a CADAS-like population doesn't bring prevalence back up. This confirms the lower prevalence isn't due to using the "wrong" coefficients for CADAS's population. The issue is that the people who would be classified as dementia (those with very low cogscore or very high relscore) simply aren't in the CADAS sample to begin with.

---

## Overall Conclusion

The evidence suggests that CADAS Cuba's lower dementia prevalence (6.2% vs 9.3%) reflects a **population difference**, not a scoring or calibration issue:

1. **Score adjustments have marginal impact** - Pentagon scoring (strict vs lenient) made no difference. Individual item differences are too small to move people across the classification threshold.

2. **The algorithm performs consistently** - When applied to comparable populations, it produces comparable results.

3. **CADAS has a different population profile** - More educated, with higher cognitive scores and less informant-reported impairment.

4. **Education explains much of the gap** - Filtering 1066 to match CADAS education levels drops prevalence substantially.

### Is the lower probability in CADAS a problem?

Rather than viewing this as "CADAS is missing impaired individuals," an equally valid interpretation is that **6.2% is the true dementia prevalence for today's Cuban elderly population**:

- CADAS was conducted ~20 years after 1066
- Cuba has seen improvements in education levels over this period
- Higher education → better cognitive reserve → lower dementia risk
- The CADAS sample (92% with primary+ education) may accurately represent the current elderly population, while 1066's sample (75% with primary+) represented an earlier cohort

**Both studies may be accurate for their respective populations and time periods.** The prevalence difference could reflect genuine population-level improvements in cognitive health, not sampling bias.

### A deeper issue: the algorithm doesn't control for education

The 10/66 algorithm was designed to be "education-fair" by using cognitive tests that theoretically shouldn't advantage educated people (recall, object naming, etc. rather than vocabulary or abstract reasoning). But in practice, educated people still perform better on these tests.

Critically, the algorithm doesn't include education as a covariate. It assumes the cognitive tests themselves are education-neutral. But they're not:

1. Educated people score higher on cogscore
2. The algorithm sees high cogscore → lower dementia probability
3. No adjustment is made for the fact that education itself drives cogscore

This means in a more educated population like CADAS, the algorithm will naturally produce lower prevalence—not necessarily because there's less dementia, but because the "education-fair" tests aren't actually education-fair.

This is a fundamental limitation of the 10/66 approach when comparing populations with different education distributions.

---

## Ideas for Improving Model Fit

### Potential Approaches

1. **Stratified models** - Run separate logistic regressions for different education or age groups, then combine predictions. This could help if the cogscore-dementia relationship differs by education level (e.g., a cogscore of 25 might mean something different for someone with primary vs. university education).

2. **Propensity score adjustment** - Weight CADAS observations to match 1066 population characteristics on education, age, etc.

3. **Recalibrate on CADAS-like 1066 subsample** - Train coefficients on the restricted 1066 sample that matches CADAS characteristics. *Tested above—doesn't increase prevalence back toward 9.3%.*

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
