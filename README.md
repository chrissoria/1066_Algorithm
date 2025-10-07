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

2. All these components are summed and weighted to produce the overall cognitive score.

*Calculation Formula:*

$$
\text{cogscore} = 1.03125 \times (\text{nametot} + \text{count} + \text{animtot} + \text{wordtot1} + \text{wordtot2} + \text{papertot} + \text{storytot})
$$

**Explanation and Handling other Datasets:**

The multiplier 1.03125 (= 33/32) is a scaling constant in the operational CSI-D code. 
The raw cognitive composite (nametot + count + animtot + wordtot1 + wordtot2 + papertot + storytot) has a maximum of 32 points (with count ≤ 26, and each of nametot, animtot, wordtot1, wordtot2, papertot, storytot ≤ 1). 
Multiplying by 33/32 linearly rescales this 0–32 sum to the canonical 0–33 CSI-D COGSCORE range. 


In some datasets, the full theoretical maximum of **32 points** cannot be reached because of missing or modified items.  In these cases, the interpretation of the **1.03125** multiplier becomes **ambiguous**.

#### Recommended Approaches

1. **Preserve the original upweighting intent**  
   Retain the fixed multiplier of **1.03125**, as it reflects the authors’ empirical calibration  
   and maintains comparability with official **10/66** scoring implementations.

2. **Dynamic normalization**  

   $$
   \text{cogscore} = \left(\frac{\text{max\_possible\_score} + 1}{\text{max\_possible\_score}}\right) \times \text{raw\_sum}
   $$