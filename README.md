# The 10/66 Dementia Classification Algorithm

The Stata do files in this repository reproduce the original 10/66 algorithm using the first two waves of the 10/66 data available <a href="https://community.addi.ad-datainitiative.org/datasets/a/d/DA61/10-66">HERE</a>. 

Information on the original algorithm can found in this paper by Prince et al.: https://bmcpublichealth.biomedcentral.com/articles/10.1186/1471-2458-8-219

This algorithm has been validated in the HRS <a href="https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-wave">ADAMS</a> data here: https://alz-journals.onlinelibrary.wiley.com/doi/10.1002/alz.086959

- The files necessary to reproduce the algorithm using 10/66 data can be found in the `10_66` folder.
- The files necessary to reproduce the algorithm using ADAMS data can be found in the `ADAMS` folder.
- The files necessary to reproduce the algorithm using CADAS data can be found in the `CADAS` folder.

### Relative Score Calculation in the Original 10/66 data

To obtain a score the relscore like in the original 10/66 formulation, we use the following formula: 

1. **Remove the Subtraction Term:**
   - Upweights \( S \) assuming some missingness.
   - New formula:

$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S
$$

where \( S \) is the total sum of all responses that supply the relscore:

$$
S = \sum_{n=1}^{n} S_i
$$

and `misstot` represents the total possible score obtainable by missing responses:

$$
\text{misstot} =  \text{miss3} \times 3 + \text{miss1}
$$

The variable `miss1` is defined as the sum of all missing values in the \( S \) column where responses are binary (yes or no):

$$
\text{miss1} = \sum_{i \in \{S_j \mid S_j \text{ is missing and binary}\}} 1
$$

The variable `miss3` is defined as the sum of all missing values in the \( S \) column where the maximum possible score is 3:

$$
\text{miss3} = \sum_{i \in \{S_j \mid S_j \text{ is missing and max score is 3}\}} 1
$$

2. **Exclude Incomplete Responses from the relscore:**

The above works well for researchers who want to keep all cases rather than drop a respondent simply because they are missing a single question that supplies the relscore. If you prefer to only include respondents who answered all questions change local drop_missing_from_relscore from "no" to "yes"
