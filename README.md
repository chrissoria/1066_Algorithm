# The 10/66 Dementia Classification Algorithm

The Stata do files in this repository reproduce the original 10/66 algorithm using both waves of the 10/66 data. The original files are located in the `10_66` folder.

### Relative Score Calculation

The relative score (`relscore`) is calculated using:

$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S - (\text{miss1} + \text{miss3}) \times 9
$$

where \( S \) is:

$$
S = \sum_{n=1}^{24} S_i
$$

**Example Relscore Calculation:**

If there are 4 negative values for `miss1` and `miss3` and the respondent scores 1.5 for \( S \):

- Left of the subtraction: \( \left( \frac{30}{30 - 0} \right) \times 1.5 = 1.5 \)
- Right of the subtraction: \( 4 \times 9 = 36 \)
- Total `relscore`: \( 1.5 - 36 = -34.5 \)

This score becomes more negative as:
A. Missingness increases.
B. \( S \) trends towards 0.

### Potential Relscore Solutions

1. **Remove the Subtraction Term:**
   - Upweights \( S \) assuming some missingness.
   - New formula:

$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S
$$

2. **Exclude Incomplete Responses:**
   - Only include respondents who answered all questions.

The default in the do files is solution 1, with an option to switch to solution 2.

### Relscore in ADAMS (HRS) data

In the ADAMS version, the maximum score is 23. Therefore, the equation is:

$$
\text{relscore} = \left( \frac{23}{23 - \text{misstot}} \right) \times S
$$

### Datasets for Reproducing the Algorithm in ADAMS 

Here are the datasets that we use to reproduce the algorithm in ADAMS:

1. **ADAMS wave A**
   - **Section B**
     - Neuropsychiatric Inventory (NPI)
     - Composite International Diagnostic Interview (CIDI depression screen)
     - Blood pressure and heart rate
   - **Section D**
     - ADAMS Consensus conference research diagnoses for dementia
     - Clinical Dementia Rating (CDR) Scale
     - Dementia Severity Rating Scale (DSRS)
     - Modified Hachinski Ischemic Score
     - Apolipoprotein E genotype Blessed Dementia Scale
     - Medical History (some)
   - **Section N**
     - Memory Impairment Screen (MIS)
     - HRS Self-report of memory problem questions 
     - Neuropsychological Measures
   - **Tracker**
     - Demographics and Field Outcomes for Waves A-C
   - **Section C**
     - Clinical History
2. **Langa-Weir Classification of Cognitive Function** (27 point scale)
   - Telephone Interview for Cognitive Status (TICS) classification in: **cogfinalimp_9520wide.dta**
3. **Gianattasio-Power Predicted Dementia Probability Scores and Dementia Classifications**
   - Modified Hurd Model in: **hrsdementia_2021_1109.dta**
4. **RAND HRS Longitudinal File and the RAND HRS Detailed Imputation File**
   - Education and race variables in: **randhrs1992_2016v2.dta**
