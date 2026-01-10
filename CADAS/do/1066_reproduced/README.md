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

| Variable | Coefficient | Std. Error | z | P>|z| |
|----------|-------------|------------|---|------|
| cogscore | -0.4001659 | 0.0268102 | -14.93 | 0.000 |
| relscore | 0.5024221 | 0.0249609 | 20.13 | 0.000 |
| recall | -0.6997248 | 0.0560805 | -12.48 | 0.000 |
| _cons | 8.486511 | 0.6831612 | 12.42 | 0.000 |

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
| `1066_step1_cogscore_prep.do` | Rename and recode cognitive test variables |
| `1066_step2_cogscore.do` | Calculate COGSCORE |
| `1066_step3_relscore_prep.do` | Rename and recode informant report variables |
| `1066_step4_relscore.do` | Calculate RELSCORE |
| `1066_step5_classify.do` | Apply classification algorithm |
| `1066_step6_save.do` | Save output to 1066.dta and excel |
| `validate_cogscore_vars.do` | Validation script to check variable values |
| `compare_new_vs_orig.do` | Compare refactored output to original |

## Configuration Options

Set these globals in `1066_master.do`:

```stata
global drop_missing_from_relscore "no"     // Drop cases with missing relscore items
global recode_disability_to "missing"      // How to handle disability codes: "zero" or "missing"
global impute_recall "no"                  // Impute delayed recall from immediate
```

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

### 4. Disability Code Handling

Physical disability codes (6, 7, 8, 9) in cognitive test items can be recoded to either:
- `"zero"` - Treat as incorrect (unable to perform = score 0)
- `"missing"` - Treat as missing data

This is controlled by the `$recode_disability_to` global.

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
