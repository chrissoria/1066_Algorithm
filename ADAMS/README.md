# The 10/66 Dementia Classification Algorithm in HRS ADAMS

The Stata do files in this repository reproduce the original 10/66 algorithm using both waves of the 10/66 data. The original files are located in the `10_66` folder.

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
