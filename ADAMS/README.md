# The 10/66 Dementia Classification Algorithm in HRS ADAMS

This folder reproduces the 10/66 dementia classification algorithm in the Aging, Demographics, and Memory Study (ADAMS) wave A — the in-person cognitive assessment substudy of the Health and Retirement Study (HRS). For background on the 10/66 algorithm itself, see the [main repository README](../README.md).

## Citation

This is the peer-reviewed paper describing and validating this implementation:

> Llibre Guerra JJ, Weiss J, Li J, Soria C, Rodriguez-Salgado A, Llibre Rodríguez JJ, Jiménez Velázquez IZ, Acosta D, Liu MM, Dow WH. **Assessing the 10/66 dementia classification algorithm for international comparative analyses with the United States.** *American Journal of Epidemiology*. 2025;194(11):3117–3125. doi: [10.1093/aje/kwae470](https://doi.org/10.1093/aje/kwae470) · [PubMed](https://pubmed.ncbi.nlm.nih.gov/39745806/) · [PMC12634119](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC12634119/)

If you use this code or data pipeline, please cite that paper.

## Overview

The validation answers one question: *how well does the 10/66 algorithm's dementia classification agree with the ADAMS expert consensus diagnosis?*

`do/hrs1066_adams_reproduced.do` runs the full pipeline:

1. **Harmonize** ADAMS wave A items onto the 10/66 concepts (see [Variable mapping](#variable-mapping) below).
2. **Score** the three input components: `COGSCORE`, `RELSCORE`, and `RECALL`.
3. **Classify** dementia by fitting `logit dementia COGSCORE RELSCORE RECALL` with 10-fold × 10-repeat cross-validation, then applying probability cutpoints. Race/ethnicity-specific models use `firthlogit`, and empirical (Liu-method) optimal cutpoints are estimated with `cutpt`.
4. **Validate** against the gold standards in ADAMS and HRS, reporting sensitivity, specificity, accuracy, predicted prevalence, and ROC AUC for each:
   - ADAMS consensus conference diagnosis (`ADFDX1`) — the primary reference standard
   - Langa-Weir 27-point TICS classification (dementia cutpoint ≤ 6)
   - Gianattasio–Power classifications (expert panel, Hurd model, LASSO)
5. **Analyze** education and race/ethnicity gradients in classification and plot dementia concentration by age.

Departures from the canonical algorithm worth knowing about:

- **Coefficients are re-estimated, not fixed.** Rather than applying the published Prince et al. coefficients with the 0.25591 threshold, this implementation refits the model in-sample via cross-validation (to guard against overfitting) and evaluates several cutpoints, including empirical and race/ethnicity-specific ones. The 0.25 published threshold is also evaluated for comparison.
- **No GMS components.** The GMS clinical diagnosis (`GMSDIAG`) and WHODAS are not available in ADAMS; classification uses `COGSCORE`, `RELSCORE`, and `RECALL` only.
- **Wave A only**; ADAMS waves B and C are not used.

## Algorithm components

### COGSCORE

Cognitive performance composite, `COGSCORE = 1.03125 × (count + animtot + wordtot1 + wordtot2 + papertot + storytot)`, where:

| Component | ADAMS source | Scaling |
|-----------|--------------|---------|
| `count` | 12 binary orientation/naming/construction items (orientation to date/place, naming pencil/watch, sentence repetition, immediate address registration, pentagon copy) | 0–1 each, summed |
| `animtot` | Animal fluency (`ANAFTOT`) | ÷ 33 |
| `wordtot1` | Immediate word recall, 3 trials (`ANMSE11S`) | ÷ 3 |
| `wordtot2` | Delayed word recall, sum of three trials (`ANMSE13`+`ANMSE14`+`ANMSE15`) | ÷ 3 |
| `papertot` | Paper-folding 3-step command (`ANMSE20F`+`ANMSE20L`+`ANMSE20R`) | ÷ 3 |
| `storytot` | Logical memory story recall (`ANWM1TOT`) | ÷ 37 |

The 1.03125 multiplier is part of the original 10/66 formulation; it rescales the score for categorical classification.

### RECALL

CERAD-style delayed word recall, `ANDELCOR`, scored 0–10.

### RELSCORE

Informant-reported functional abilities, weighted up for missing items. ADAMS items cover a maximum of 23 points (versus 30 in the original), so:

$$
\text{relscore} = \left( \frac{23}{23 - \text{misstot}} \right) \times S
$$

where $S$ is the sum of rescaled item responses (missing treated as 0) and $\text{misstot} = 3 \times \text{miss3} + \text{miss1}$, counting missing responses by their maximum possible value. The weighting assumes that items missing at random do not change the expected total.

Informant items include memory complaints and domain ratings (memory, orientation, word-finding, judgment), the Blessed Dementia Scale functional subscale (chores, money, getting around, lost), and three ADLs (feeding, dressing, toileting) plus hobby interest. Rescaling rules per item are in the do file (e.g., word-finding: 0 / 0.5 / 1).

### Missing-data and recoding rules

- ADAMS codes 97/98/99 (don't know, refusal, other) → missing, **except** for the 12 binary COGSCORE items, where `recode 98 = 0`: the original 10/66 items had no "don't know" option, so a wrong or absent answer is scored incorrect. This choice is reflected in the output log's name (`ADAMS_1066_aggressive_98_to_0.log`).
- `aWATCH`/`aPENCIL` "correct with tactile stimulus" (code 2) is recoded to correct (1).
- **Physical disability:** if the informant says an ADL (dressing, toileting, feeding, chores) is limited by physical rather than cognitive difficulty, that item contributes 0 to `RELSCORE` instead of being treated as dementia-evidence.

## Classification and validation details

**Writing the classification into the data.** Each 10-fold CV run predicts out-of-fold probabilities; 10 repeats are averaged (`k_fold_dem_pred_1066_av`). Binary classifications are built from this average:

| Variant | Cutpoint |
|---------|----------|
| Published threshold, pooled model | 0.25 |
| Empirically optimal (Liu method), pooled model | 0.1166 (`cutpt`) |
| Published threshold, race/ethnicity-specific `firthlogit` models | 0.25 |
| Empirically optimal, race/ethnicity-specific | White 0.0894, Black 0.2513, Hispanic 0.8837 |

**Sample.** The analytic sample is complete-cased: respondents with non-missing age, `COGSCORE`, `RELSCORE`, `RECALL`, diagnosis, demographics, **and** non-missing external classifier scores (Langa-Weir 2000/2002, Hurd/expert/LASSO probabilities). Missingness is dominated by incomplete COGSCORE — the do file's own comments note ~927 respondents lack a complete score versus ~589 who have one. In the run's log, dropping respondents with no consensus diagnosis removes 701 observations (n = 815), the complete-case filters remove a further 307, leaving the analytic sample.

**Race/ethnicity categories:** White non-Hispanic, Black non-Hispanic, Hispanic (from RAND `raracem`/`rahispan`). **Education categories:** <high school, high school graduate, some college or more (RAND `raeduc`).

## Data sources and access

ADAMS wave A is **restricted** and not distributed with this repository. Access must be arranged through the NIA/ISR — see the [ADAMS wave A data products page](https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-wave) for the application process and documentation.

The three public HRS files below can be downloaded directly and are merged in by `hhidpn` (household ID + person number):

| File | Source | Used for |
|------|--------|----------|
| `randhrs1992_2016v2.dta` | [RAND HRS archived data products](https://hrsdata.isr.umich.edu/data-products/rand-hrs-archived-data-products) | `raeduc`, `raracem`, `rahispan`, `ragender` |
| `cogfinalimp_9520wide.dta` | [Cross-wave imputation of cognitive functioning, 1992–2020](https://hrsdata.isr.umich.edu/data-products/cross-wave-imputation-cognitive-functioning-measures-1992-2020) | Langa-Weir cognitive scores (`cogtot27_imp2000`/`2002`) |
| `hrsdementia_2021_1109.dta` | [Gianattasio–Power dementia probability scores](https://hrsdata.isr.umich.edu/data-products/gianattasio-power-predicted-dementia-probability-scores-and-dementia-classifications) | `expert_dem`, `hurd_dem`, `lasso_dem` + probability scores |

The ADAMS consensus diagnosis, CDR, Blessed scales, and neuropsychological items all come from the restricted ADAMS wave A files themselves (sections B, C, D, N, and the tracker).

## Variable mapping

As [Llibre Guerra et al. (2025)](https://doi.org/10.1093/aje/kwae470) describe, the first step of this implementation is identifying which 10/66 algorithm items are comparably measured in ADAMS. All 10/66 → ADAMS item correspondences and rescaling rules (46 items across COGSCORE, RECALL, RELSCORE, and the physical-disability sub-items) are documented in:

- `mapping/full_detailed_mapping.csv` — item-by-item mapping with ADAMS value labels and recoding notes
- `mapping/full_mapping.csv` — condensed version

## File structure

| File | Description |
|------|-------------|
| `do/read.do` | Ingests raw ADAMS ASCII extracts (`.dct`), builds `hhidpn` keys, and merges ADAMS sections B/D/N (+C) into `DTA/ADAMS_WAVE_A_aggressive.dta`; restricts the Gianattasio–Power file to HRS 2000/2002 (removing duplicate IDs) and builds keyed copies of the two public HRS files. **Note:** the script ends with an exploratory merge of the dementia probability data and does not save the fully merged dataset — see step 4 below. |
| `do/hrs1066_adams_reproduced.do` | Main pipeline: harmonization, scoring, cross-validated classification, validation against all four reference standards, gradient analyses, and plots. Exports `data/probabilities_classification.csv` and age-gender plots (paths are relative to the working directory set at the top of the script, the 1066 repo root). |
| `do/within_1066_comparison.do` | Sensitivity analysis running the 10/66 algorithm on the original 10/66 data restricted to items available in CADAS, for cross-dataset comparison. |
| `mapping/` | Variable mapping CSVs (above) |
| `logs/` | Stata output logs from completed runs |
| `plots/` | Output figures (classification probabilities, dementia by age/gender, education gradients) and the Python notebook producing them |

## Reproducing

1. **Arrange data access.** Apply for the restricted ADAMS wave A files; download the three public HRS files listed above.
2. **Install user-written Stata packages** (needed by the main script): `firthlogit` (bias-reduced logit), `cutpt` (empirical ROC cutpoints), and `estout` (`eststo` stores results). All are available via `ssc install <name>`.
3. **Fix the paths.** `read.do` and `hrs1066_adams_reproduced.do` use hardcoded absolute paths (lines at the top and in every `use`/`merge`/`log` statement) pointing at the original working directory. Search-and-replace them with your local directories, and place the raw ADAMS ASCII extracts under `adams1asta/` (the `.dct` filenames read by `read.do`). Then run, in order:

   ```stata
   do "do/read.do"                      // build DTA inputs (only needed once)
   ```

4. **Provide the final input files.** The main script merges the three external files into `DTA/ADAMS_WAVE_A_aggressive.dta` itself, so no manual merge is needed — but it expects the 2000/2002-restricted Gianattasio–Power file under the name `DTA/hrsdementia_2021_1109_2002.dta`, whereas `read.do` saves that restricted version as `hrsdementia_2021_1109_reproduced.dta` in a different folder. Rename/move it, or adjust the path in the main script.

5. **Run the pipeline:**

   ```stata
   do "do/hrs1066_adams_reproduced.do"  // full pipeline
   ```

6. **Check the outputs.** Validation statistics (sensitivity/specificity/accuracy/prevalence/AUC per reference standard) print in the log; per-person predicted probabilities and classifications are exported to `data/probabilities_classification.csv` (also checked in under `ADAMS/data/`).

## See also

- **Llibre Guerra et al. (2025)** — [doi:10.1093/aje/kwae470](https://doi.org/10.1093/aje/kwae470), [PubMed](https://pubmed.ncbi.nlm.nih.gov/39745806/): reports full validation results from this pipeline (87% sensitivity, 93% specificity against the ADAMS clinical diagnosis) and comparisons with the four other ADAMS-validated algorithms.
- **Prince et al. (2008)** — the original 10/66 algorithm specification: [10.1186/1471-2458-8-219](https://doi.org/10.1186/1471-2458-8-219)
- **[CADAS folder](../CADAS/README.md)** — the same algorithm applied to Cuban and Dominican data
- **[Main repository README](../README.md)** — algorithm overview and general references

## Limitations

- **Complete-case analytic sample.** Requiring non-missing external classifier scores and complete COGSCORE excludes most of ADAMS wave A; results describe respondents with complete data.
- **Race/ethnicity-specific estimates are unstable in small strata.** The Hispanic empirical cutpoint (0.88) in particular looks driven by a very small number of positives (≈84 Hispanic respondents out of the 815 with diagnosis). The logged race-specific results include a stratum with a perfect AUC (1.00), the signature of near-perfect separation in a small sample.
- **No GMS diagnosis or WHODAS** in ADAMS, so the classification omits those components of the original algorithm.
- The aggressive 98 → 0 recoding for binary COGSCORE items is a judgment call; alternative treatments are plausible and could be included as a sensitivity analysis.
