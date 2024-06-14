# 1066_Algorithm

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

**Example Calculation:**

If there are 4 negative values for `miss1` and `miss3` and the respondent scores 1.5 for \( S \):

- Left of the subtraction: \( \left( \frac{30}{30 - 0} \right) \times 1.5 = 1.5 \)
- Right of the subtraction: \( 4 \times 9 = 36 \)
- Total `relscore`: \( 1.5 - 36 = -34.5 \)

This score becomes more negative as:
A. Missingness increases.
B. \( S \) trends towards 0.

### Potential Solutions

1. **Remove the Subtraction Term:**
   - Upweights \( S \) assuming some missingness.
   - New formula:
$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S
$$

2. **Exclude Incomplete Responses:**
   - Only include respondents who answered all questions.

The default in the do files is solution 1, with an option to switch to solution 2.

### ADAMS Version

In the ADAMS version, the maximum score is 23. Therefore, the equation is:
$$
\text{relscore} = \left( \frac{23}{23 - \text{misstot}} \right) \times S
$$
