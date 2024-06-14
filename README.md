# 1066_Algorithm

The following Stata do files reproduce the original 10/66 algorithm to the best of our ability using both waves of the original 10/66 data. These original files can be found in the 10_66 folder. 


### Relative Score Calculation

The relative score (`relscore`) is calculated using the following formula:

$$
\text{relscore} = \left( \frac{R}{R - \text{misstot}} \right) \times \sum_{n=1}^{r} S_i - (\text{miss1} + \text{miss3}) \times 9
$$

where \( R \) is defined as the maximum possible score obtainable by the relscore

And 

\(r \) is defined as the total amount of questions that are supplying the relscore