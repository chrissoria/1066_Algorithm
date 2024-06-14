# 1066_Algorithm

The following Stata do files reproduce the original 10/66 algorithm to the best of our ability using both waves of the original 10/66 data. These original files can be found in the 10_66 folder. 

### Relative Score Calculation

The relative score (`relscore`) is calculated using the following formula:

$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S - (\text{miss1} + \text{miss3}) \times 9
$$

where \( S \) is defined as:

$$
S = \sum_{n=1}^{24} S_i
$$

For example, let’s say that there are 4 negative values between miss1 and miss3 and the respondent only got a 1.5 score for \( S \). In this case, everything to the left of the subtraction sign will be 1.73; however, everything to the right of the subtraction sign will be \( 4 \times 9 = 36 \), and the total `relscore` will be -34.26. This score becomes more negative as:

A. More missingness is introduced.
B. The value for \( S \) trends towards 0. 

There are 2 potential solutions to this:

1. We remove everything after the minus sign from the equation. This will upweight the value for \( S \) and assume that some random set of 0 in the \( S \) column is due to missingness. This is essentially a missing-weighted version of the \( S \) column. This makes the most sense to me.
   - This leaves us with this equation:
     $$
     \text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S
     $$
2. We can remove all people who do not answer the complete set of questions and make no assumptions.