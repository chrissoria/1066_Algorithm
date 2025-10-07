# The 10/66 Dementia Classification Algorithm

The 10/66 algorithm was designed to help identify dementia using a set of standard tests and interviews. It works by combining information from several sources:

- Memory and thinking tests
- Interviews with the person being assessed
- Reports from someone who knows the person well

The 10/66 algorithm uses results from well-known tools, such as the Community Screening Instrument for Dementia, the CERAD 10-word recall and animal-naming tests, and structured clinical interviews. It follows guidelines from the DSM-IV, a widely used manual for diagnosing dementia, but puts these rules into a step-by-step process a computer can follow.

The goal is to make dementia diagnosis more consistent and reliable, especially in large studies. The algorithm was checked against expert clinical diagnoses to make sure it works well. It tends to identify people with clear, significant dementia but may miss milder cases. Compared to other methods, it is more specific but less sensitive, meaning it is good at confirming dementia when it is present, but might not catch every case.

Note: This version of the algorithm does not use depression measures in its process.

The Stata do files in this repository reproduce the original 10/66 algorithm using the first two waves of the 10/66 data available <a href="https://community.addi.ad-datainitiative.org/datasets/a/d/DA61/10-66">HERE</a>. 

Information on the original algorithm can found in this paper by Prince et al.: https://bmcpublichealth.biomedcentral.com/articles/10.1186/1471-2458-8-219

This algorithm has been validated in the HRS <a href="https://hrsdata.isr.umich.edu/data-products/aging-demographics-and-memory-study-adams-wave">ADAMS</a> data here: https://alz-journals.onlinelibrary.wiley.com/doi/10.1002/alz.086959

- The files necessary to reproduce the algorithm using 10/66 data can be found in the `10_66` folder.
- The files necessary to reproduce the algorithm using ADAMS data can be found in the `ADAMS` folder.
- The files necessary to reproduce the algorithm using CADAS data can be found in the `CADAS` folder.

### Relative Score Calculation in the Original 10/66 data

To obtain a score the `relscore` like in the original 10/66 formulation, we use the following formula: 

1. We calculate the sum of informant reports on the respondent.  
Here, we will label this sum as \( `S` \). See  [a full variable mapping list](https://github.com/chrissoria/1066_Algorithm/blob/main/ADAMS/mapping/full_detailed_mapping.csv) for all variables to include in the \( `S` \) vector.

$$
S = \sum \text{(informant reports on cognitive and physical ability of the respondent)}
$$

2. **Remove the Subtraction Term:**
   - Upweights \( `S` \) assuming some missingness.
   - New formula:

$$
\text{relscore} = \left( \frac{30}{30 - \text{misstot}} \right) \times S
$$

where, as a reminder, \( S \) is the total sum of all responses that supply the relscore:

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

3. **Exclude Incomplete Responses from the relscore:**

The above works well for researchers who want to keep all cases rather than drop a respondent simply because they are missing a single question that supplies the relscore. If you prefer to only include respondents who answered all questions change local drop_missing_from_relscore from "no" to "yes"

### Cognitive Score Calculation in the Original 10/66 data

To calculate the `cogscore`, aggregate the results from several domains measured during assessment:

1. Sum up all of these individual scores

- `nametot`: Ability to say and remember the interviewer's name.
- `count`: Ability to identify common objects, repeat simple words, orient in space/time, and demonstrate motor skills.
- `animtot`: Quickly list the names of animals.
- `wordtot1`: Immediate recall of words.
- `wordtot2`: Delayed recall of words.
- `papertot`: Ability to fold paper and follow instructions.
- `storytot`: Ability to recall the elements of a story.

Let the raw sum of these components be:

$$
C = \text{nametot} + \text{count} + \text{animtot} + \text{wordtot1} + \text{wordtot2} + \text{papertot} + \text{storytot}
$$

2. All these components are summed and weighted to produce the overall cognitive score.

*Calculation Formula:*

$$
\text{cogscore} = 1.03125 \times C
$$

**Explanation of weighting and handling other datasets:**

The multiplier 1.03125 (= 33/32) is a scaling constant in the operational CSI-D code.  
The raw cognitive composite `C` has a maximum of 32 points (with `count ≤ 26`, and each of `nametot`, `animtot`, `wordtot1`, `wordtot2`, `papertot`, `storytot ≤ 1`).  
Multiplying by 33/32 linearly rescales this 0–32 sum to the canonical 0–33 CSI-D COGSCORE range.  

In some datasets, the full theoretical maximum of **32 points** cannot be reached because of missing or modified items. In these cases, the interpretation of the **1.03125** multiplier becomes **ambiguous**.

#### Recommended Approaches

1. **Preserve the original upweighting intent**  
   Retain the fixed multiplier of **1.03125**, as it reflects the authors’ empirical calibration  
   and maintains comparability with official **10/66** scoring implementations.

2. **Dynamic normalization**

$$
\text{cogscore} = \left( \frac{C_{\max} + 1}{C_{\max}} \right) \times C
$$

Note: this normalization simply adjusts the range of the composite score.
If a logistic or discriminant model (like the 10/66 algorithm) is re-fitted after scaling, it automatically compensates for this change.
However, if the model coefficients are fixed (as in the official algorithm), scaling the input score (e.g., multiplying by a constant) will alter its effective weight and therefore shift the resulting probabilities and classifications.

### Incorporating CERAD ten-word delayed recall

The `Recall` variable, representing the delayed recall score from the ten-word list-learning task, is one of the most important components of the 10/66 diagnostic algorithm. It captures episodic memory, which is a central cognitive domain affected early in dementia. That is, delayed recall is one of the strongest independent predictors of dementia, with odds of true dementia increasing sharply as recall performance declined. Within the 10/66 framework, it forms a core part of the combined predictive model, as important as the CSI-D cognitive and informant scores. 

Here, we do not compute an index or new composite. Instead, we retain `Recall` as a standalone variable to be included later as a covariate in the predictive model.

### Generating binned variables

The above, alongside the GMS Diagnosis, form the core components of the **10/66 Dementia Diagnostic Algorithm**.
Each continuous variable is first **converted into categorical bands** before being assigned a corresponding weight in the final predictive model.
You can review how these variables are categorized and scored in the following section of the code:

[Full_Algo_Computation.do — Lines 394–444](https://github.com/chrissoria/1066_Algorithm/blob/10109417901debc63fd36ac361d1a509d140ccad/10_66/do/Full_Algo_Computation.do#L394-L444)

The resulting variables are the `brelscor` (informant report), `bcogscor` (cognitive score), `bdelay` (delayed recall), and `bgmsdiag` (GMS diagnosis).

**Note:**  
In datasets other than the original training sample, it is often preferable to **retain the continuous versions** of these variables when re-estimating or adapting the model. 
The original category thresholds were derived from the empirical distributions of the 10/66 training data; applying them unchanged to new populations may introduce **miscalibration** rather than overfitting, since score ranges and variances can differ across studies.

### Generating the 10/66 Dementia Score and Classification

1. Each of the four weighted components—`brelscor`, `bcogscor`, `bdelay`, and `bgmsdiag`—are summed into a single linear index `Q`.

$$
Q = b_{\text{relscore}} + b_{\text{cogscore}} + b_{\text{delay}} + b_{\text{gmsdiag}}
$$

2. An intercept of **−9.53**, estimated from the original logistic regression model in *Prince et al.* (2003, *The Lancet*), is then added to align the model with the baseline dementia prevalence observed in the 10/66 training sample. 
This intercept represents the model’s constant term—the baseline log-odds of dementia when all predictors are at their lowest levels.

$$
\text{logit}(p) = -9.53 + Q
$$

3. The exponential of this value converts log-odds to odds, which are then transformed into a probability between 0 and 1.

$$
p = \frac{e^{\text{logit}(p)}}{1 + e^{\text{logit}(p)}}
$$

4. Finally, participants are classified as having **probable dementia** if their predicted probability exceeds 0.25591, the empirically derived threshold that maximized sensitivity and specificity in the original 10/66 validation sample; those below this cutoff are classified as **non-cases**.

$$
\text{dem1066} =
\begin{cases}
1, & \text{if } p > 0.25591 \\
0, & \text{if } p \leq 0.25591
\end{cases}
$$

---

For any questions, concerns, or suggestions, please email Chris Soria at chrissoria@berkeley.edu.