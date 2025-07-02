# The 10/66 Dementia Classification Algorithm in HRS ADAMS

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
3. **Gianattasio-Power Predicted Dementia Probability Scores and Dementia Classifications**More actions
   - Modified Hurd Model in: **hrsdementia_2021_1109.dta**
4. **RAND HRS Longitudinal File and the RAND HRS Detailed Imputation File**
   - Education and race variables in: **randhrs1992_2016v2.dta**