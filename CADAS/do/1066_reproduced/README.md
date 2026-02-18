# 10/66 Dementia Classification Algorithm for CADAS

This directory contains a modular implementation of the 10/66 dementia classification algorithm adapted for the CADAS (Cuba and Dominican Republic Aging Study) dataset.

For general information about the 10/66 algorithm, see the [main repository README](https://github.com/chrissoria/1066_Algorithm/blob/main/README.md).

## Overview

The algorithm classifies dementia using three main components:
- **COGSCORE**: Cognitive performance composite from direct assessment
- **RELSCORE**: Informant-reported functional abilities
- **RECALL**: CERAD 10-word delayed recall (0-10)

**Note:** This implementation does not use GMSDIAG (GMS clinical diagnosis) or WHODAS, as these are not available in CADAS.

## Coefficients

The classification uses logistic regression coefficients derived from the original 10/66 training data. These coefficients were extracted by running `logit cdem1066 cogscore relscore recall` on the 1066 baseline data (n=6,791).

### Dementia Probability Formula

$$
p = \frac{e^{L}}{1 + e^{L}}
$$

where:

$$
L = 8.486511 - 0.4001659 \times \text{cogscore} + 0.5024221 \times \text{relscore} - 0.6997248 \times \text{recall}
$$

### Coefficients Table

| Variable | Coefficient | Std. Error | z | P>\|z\| |
|----------|-------------|------------|-------|---------|
| cogscore | -0.4001659 | 0.0268102 | -14.93 | 0.000 |
| relscore | +0.5024221 | 0.0249609 | 20.13 | 0.000 |
| recall | -0.6997248 | 0.0560805 | -12.48 | 0.000 |
| _cons | +8.486511 | 0.6831612 | 12.42 | 0.000 |

### Classification Threshold

Cases are classified as dementia-positive if:

$$
\text{dem1066} =
\begin{cases}
1, & \text{if } p \geq 0.5 \\
0, & \text{if } p < 0.5
\end{cases}
$$

## File Structure

| File | Description |
|------|-------------|
| `1066_master.do` | Main orchestration file with configuration options |
| `1066_step0_data_load.do` | Load and merge Cog, Infor, Cog_Scoring datasets |
| `1066_step05_pre_prep_cog_vars.do` | Pre-preparation: recode missing/disability to 0, impute circle/animals/pentagon |
| `1066_step1_cogscore_prep.do` | Rename and recode cognitive test variables |
| `1066_step2_cogscore.do` | Calculate COGSCORE (includes storytot imputation) |
| `1066_step3_relscore_prep.do` | Rename and recode informant report variables |
| `1066_step4_relscore.do` | Calculate RELSCORE |
| `1066_step5_classify.do` | Apply classification algorithm |
| `1066_step6_save.do` | Save output, export diagnostics for missing scores |
| `1066_step7_validate_vs_baseline.do` | Validation against 1066 baseline data |
| `1066_step8_sample_attrition.do` | Sample attrition analysis |
| `diagnose_missing_cogscore.do` | Standalone diagnostic for missing cogscore cases |
| `validate_cogscore_vars.do` | Validation script to check variable values |
| `compare_new_vs_orig.do` | Compare refactored output to original |

## Configuration Options

Set these globals in `1066_master.do`:

```stata
global drop_missing_from_relscore "no"   // Drop cases with missing relscore items
global impute_recall "yes"               // Impute delayed recall from immediate
global use_strict_pentag "no"            // Pentagon scoring: "yes" = only value 2, "no" = 1 and 2
global run_pre_prep "yes"                // Run step 0.5 pre-preparation (recode + impute)
```

The `run_pre_prep` global is the master switch controlling whether disability codes, refusals, and missing values are recoded to 0 via `_recoded` variables in step 0.5. When set to `"no"`, step 1 falls back to inline recoding.

## CADAS-Specific Adaptations

### 1. Reason Variable Recode

In the original 1066 data, `reason` (change in ability to reason) is binary:
- 0 = no change
- 1 = yes, some change

In CADAS, `reason` has 3 levels:
- 0 = no
- 1 = si algunas veces (yes, sometimes)
- 2 = si regularmente (yes, regularly)

**We collapse to binary** (`replace reason = 1 if reason == 2`) to match the original 1066 structure, since the coefficients were trained on binary values.

### 2. Season and Longmem Variables

In CADAS, `season` and `longmem` are computed by summing two source variables (e.g., `c_2_p_c` + `c_2_d`). Some cases have data in both sources, producing values of 2.

**We cap these at 1** since they should be binary:
```stata
replace season = 1 if season > 1 & !missing(season)
replace longmem = 1 if longmem > 1 & !missing(longmem)
```

### 3. Circle Variable

The `circle` variable (circle drawing task) is included in the COGSCORE `count` component. This matches the original 1066 algorithm and the model that generated the coefficients.

**Note:** Some earlier CADAS implementations omitted `circle` from count. The current implementation correctly includes it.

## Pre-Preparation: Recoding and Imputation (Step 0.5)

When `run_pre_prep = "yes"`, step 0.5 (`1066_step05_pre_prep_cog_vars.do`) creates `_recoded` versions of all source variables before they enter the COGSCORE calculation. This centralizes all value recoding and imputation in a single script, controlled by the master switch.

### Recoding Rules

For each source variable, a `_recoded` copy is created with the following transformations:

| Original Value | Meaning | Recoded Value |
|---------------|---------|---------------|
| `.` (system missing) | Not administered / unknown | `0` |
| `.i` | Invalid skip | `0` |
| `.v` | Valid skip | `0` |
| `6` | Physical disability (could not perform) | `0` |
| `7` | Physical disability (could not perform) | `0` |
| `8` | Don't know | `0` |
| `9` | Refused | `0` |

Additionally, out-of-range and data-entry-error values are recoded to missing (`.`) so they can be handled by imputation or excluded:

| Original Value | Meaning | Recoded Value |
|---------------|---------|---------------|
| `11` | Data entry error flag | `.` (missing) |
| `5`, `23` | Typos in circle drawing (`cs_72_1`) | `.` (missing) |
| `777` | Refused/invalid in animal naming (`cs_40`) | `.` (missing) |
| `> 45` | Out of range in animal naming (`cs_40`) | `.` (missing) |

**Rationale:** Disability (codes 6, 7), don't-know (code 8), and refusal (code 9) responses are treated as inability to perform the task correctly, scored as 0 (incorrect). This maximizes sample retention by avoiding listwise deletion from the COGSCORE formula.

**Exception — Story recall (`c_66a`–`c_66f`):** True system missing (`.`) is preserved as missing (not recoded to 0) so that `storytot` remains missing and becomes eligible for imputation from the learning trials. Only `.i`, `.v`, and codes 6–9 are recoded to 0.

### Variables Recoded

| Variable Group | Source Variables | Feeds Into |
|---------------|-----------------|------------|
| Object naming | `c_24, c_25, c_48–c_56, c_26, c_8` | `count` (26 binary items) |
| Chief/president | `c_70_p` (PR) / `c_70_d_c` (DR, Cuba) | `count` |
| Informant memory | `i_a2, i_a3, i_a4` | `count` |
| Orientation | `c_1, c_3, c_5` | `count` |
| Season | `c_2_p_c`, `c_2_d` (DR only) | `count` |
| Motor commands | `c_61, c_62` | `count` |
| Long-term memory | `c_69_p` (PR) / `c_69_c, c_69_d` (DR, Cuba) | `count` |
| Immediate word recall | `c_11, c_12, c_13` | `wordimm` → `wordtot1` |
| Delayed word recall | `c_21, c_22, c_23` | `worddel` → `wordtot2` |
| Paper folding | `c_27, c_28, c_29` | `paper` → `papertot` |
| Story recall | `c_66a`–`c_66f` | `story` → `storytot` |
| Learning trials | `c_33_1`–`c_33_10`, `c_34_1`–`c_34_10`, `c_35_1`–`c_35_10` | `learn1–3` → `immed` |
| Name recall | `c_0, c_65` | `nametot` |

### Variables NOT Recoded (Handled via Imputation)

The following variables are **not** blanket-recoded to 0. Instead, missing values are preserved and filled using regression imputation:

| Variable | Description | Imputation Model |
|----------|-------------|-----------------|
| `cs_72_1` | Circle drawing score | See Imputation 1 below |
| `cs_40` | Animal naming count | See Imputation 2 below |
| `cs_32` | Pentagon drawing score | See Imputation 3 below |
| `storytot` | Story recall (normalized) | See Imputation 4 below |

### Imputation Models

All imputations use OLS regression: fit on non-missing cases, then predict to fill missing values.

#### Imputation 1: Circle Drawing (`cs_72_1`)

**Primary model:**

$$
\widehat{cs{\_}72{\_}1} = \hat{\beta}_0 + \hat{\beta}_1 \cdot cs{\_}32 + \hat{\beta}_2 \cdot cs{\_}72{\_}2 + \hat{\beta}_3 \cdot cs{\_}72{\_}3 + \hat{\beta}_4 \cdot cs{\_}72{\_}4
$$

Predictors: pentagon score and other visuospatial scoring items from the same drawing task.

**Fallback model** (for cases still missing after primary):

$$
\widehat{cs{\_}72{\_}1} = \hat{\beta}_0 + \hat{\vec{\beta}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}15) + \hat{\vec{\gamma}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}16)
$$

Predictors: informant-reported items on getting lost outside (`i_f_csid_15`) and inside (`i_f_csid_16`), entered as factor indicators.

#### Imputation 2: Animal Naming (`cs_40`)

$$
\widehat{cs{\_}40} = \hat{\beta}_0 + \hat{\vec{\beta}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}9) + \hat{\vec{\gamma}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}10)
$$

Predictors: informant-reported items on word-finding difficulty (`i_f_csid_9`) and using wrong words (`i_f_csid_10`), entered as factor indicators.

#### Imputation 3: Pentagon Drawing (`cs_32`)

**Primary model:**

$$
\widehat{cs{\_}32} = \hat{\beta}_0 + \hat{\beta}_1 \cdot cs{\_}72{\_}1 + \hat{\beta}_2 \cdot cs{\_}72{\_}2 + \hat{\beta}_3 \cdot cs{\_}72{\_}3 + \hat{\beta}_4 \cdot cs{\_}72{\_}4
$$

Predictors: circle score and other visuospatial scoring items.

**Fallback model** (for cases still missing after primary):

$$
\widehat{cs{\_}32} = \hat{\beta}_0 + \hat{\vec{\beta}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}15) + \hat{\vec{\gamma}} \cdot \mathbf{I}(i{\_}f{\_}csid{\_}16)
$$

Same informant-reported fallback predictors as circle drawing.

#### Imputation 4: Story Recall (`storytot`)

$$
\widehat{storytot} = \hat{\beta}_0 + \hat{\beta}_1 \cdot immed
$$

where:

$$
immed = \sum_{k \in \{1,2,3\}} learn_{k}, \quad learn_{k} = \sum_{j=1}^{10} c_{(33+k-1),j}
$$

Predictor: total immediate recall across three learning trials (0–30). This leverages the correlation between immediate learning and delayed story recall to recover cases where the story was not administered.

## COGSCORE Components

| Component | Description | Max Score | Normalization |
|-----------|-------------|-----------|---------------|
| nametot | Name recall (interviewer's name) | 1 | Binary |
| count | Sum of 26 binary cognitive items | 26 | Raw sum |
| animtot | Animal naming | 45 | animals/23 |
| wordtot1 | Immediate word recall | 3 | wordimm/3 |
| wordtot2 | Delayed word recall | 3 | worddel/3 |
| papertot | Paper folding | 3 | paper/3 |
| storytot | Story recall | 6 | story/6 |

**Formula:**
$$
\text{cogscore} = 1.03125 \times (\text{nametot} + \text{count} + \text{animtot} + \text{wordtot1} + \text{wordtot2} + \text{papertot} + \text{storytot})
$$

## RELSCORE Components

24 informant-reported items covering:
- Cognitive/behavioral changes (21 items)
- Activities of daily living (3 items: feed, dress, toilet)

**Items divided by 2** (scored 0-2 in original): put, kept, frdname, famname, convers, wordfind, wordwrg, past, lastsee, lastday, orient, lostout, lostin, chores, change, money

**Items NOT divided by 2** (binary): mental, activ, memory, hobby, reason

**Formula:**
$$
\text{relscore} = U \times S
$$

where:
- $S$ = sum of all informant items (missing treated as 0)
- $U = \frac{30}{30 - \text{misstot}}$ (weighting factor for missing items)
- $\text{misstot} = (\text{miss3} \times 3) + \text{miss1}$

## Running the Algorithm

1. Set user and country in the CADAS configuration files:
   - `/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_user_define.do`
   - `/Users/chrissoria/Documents/CADAS/Do/Read/CADAS_country_define.do`

2. Run the master file:
```stata
do "/Users/chrissoria/Documents/CADAS/do/1066_reproduced/1066_master.do"
```

3. Output is saved to:
   - `1066.dta` (Stata format)
   - `excel/1066.xlsx` (Excel format)

## Validation

Run the validation script after the master file to check variable values:
```stata
do "/Users/chrissoria/Documents/CADAS/do/1066_reproduced/validate_cogscore_vars.do"
```

This checks that:
- Binary items are 0/1
- Normalized scores are in expected ranges
- No unexpected values exist

## Contact

For questions, contact Chris Soria at chrissoria@berkeley.edu.
