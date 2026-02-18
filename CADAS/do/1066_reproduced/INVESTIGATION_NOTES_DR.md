# Investigation: Dementia Prevalence in CADAS Dominican Republic Sample

## Problem
CADAS Dominican Republic dementia prevalence (~X.X%) compared to 1066 baseline (~X.X%)

---

## Sample Sizes

| Dataset | N |
|---------|---|
| CADAS DR | X,XXX |
| 1066 DR | 2,011 |

---

## Where does CADAS differ from 1066 on key variables?

| Variable | CADAS | 1066 | Difference | Interpretation |
|----------|-------|------|------------|----------------|
| **cogscore** | XX.X | XX.X | +X% | CADAS has higher/lower cognitive scores |
| **relscore** | X.XX | X.XX | -X% | CADAS has less/more informant-reported impairment |
| **recall** | X.XX | X.XX | -X% | CADAS lower/higher |
| worddel | X.XX | X.XX | +X% | CADAS better/worse on 3-word delayed recall |
| story | X.XX | X.XX | +X% | CADAS better/worse on story recall |
| pentag | X.XX | X.XX | +X% | Scoring difference |
| misstot | X.XX | X.XX | ~Xx | Missing informant data comparison |

**What this means:** [To be filled in based on data]

---

## How do the CADAS and 1066 DR sample distributions compare?

| Dataset | Dementia Prevalence |
|---------|---------------------|
| CADAS DR | X.X% |
| 1066 DR | X.X% |

The following distribution comparisons reveal *why* the samples produce different prevalence rates.

---

### Does CADAS have less informant-reported impairment?

| Dataset | Mean | SD | Max |
|---------|------|-----|-----|
| CADAS DR | X.XX | X.XX | XX |
| 1066 DR | X.XX | X.XX | XX |

![Relscore Distribution](../../Data/DR_out/plots/relscore_distribution_dominican_republic.png)

**Result:** [To be filled in based on data]

---

### Does CADAS have higher cognitive scores?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS DR | XX.XX | X.XX |
| 1066 DR | XX.XX | X.XX |

![Cogscore Distribution](../../Data/DR_out/plots/cogscore_distribution_dominican_republic.png)

**Result:** [To be filled in based on data]

---

### Does CADAS have different recall scores?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS DR | X.XX | X.XX |
| 1066 DR | X.XX | X.XX |

![Recall Distribution](../../Data/DR_out/plots/recall_distribution_dominican_republic.png)

**Result:** [To be filled in based on data]

---

### Does age explain the difference?

| Dataset | Mean | SD |
|---------|------|-----|
| CADAS DR | XX.XX | X.XX |
| 1066 DR | XX.XX | X.XX |

![Age Distribution](../../Data/DR_out/plots/age_distribution_dominican_republic.png)

**Result:** [To be filled in based on data]

---

### Does education explain the difference?

| Dataset | % Primary+ |
|---------|------------|
| CADAS DR | XX.X% |
| 1066 DR | XX.X% |

![Education Comparison](../../Data/DR_out/plots/education_comparison_dominican_republic.png)

**Result:** [To be filled in based on data]

---

## Validation Tests

### What happens if we apply CADAS-like filters to 1066?

| Step | Filter Applied | N | Prevalence | Change |
|------|----------------|---|------------|--------|
| 0 | None (full 1066 DR) | 2,011 | X.X% | — |
| 1 | Education (PEDUC >= 3) | X,XXX | ~X.X% | -X.X pp |
| 2 | Cogscore (>= 20) | X,XXX | ~X.X% | -X.X pp |
| 3 | Relscore (<= 20) | X,XXX | ~X.X% | -X.X pp |

**Result:** [To be filled in based on data]

---

### How much does education alone explain?

| Sample | N | Prevalence | Cogscore Mean | Cogscore SD |
|--------|---|------------|---------------|-------------|
| Full 1066 DR | 2,011 | X.X% | XX.XX | X.XX |
| Education-restricted (PEDUC >= 3) | X,XXX | ~X.X% | XX.XX | X.XX |

**Result:** [To be filled in based on data]

---

## Overall Conclusion

[To be filled in after analyzing the data]

The evidence suggests that CADAS DR's dementia prevalence reflects:

1. **[Finding 1]** - Description

2. **[Finding 2]** - Description

3. **[Finding 3]** - Description

### Is the prevalence difference a problem?

[Analysis to be added]

### Comparison with Cuba findings

| Metric | Cuba | DR |
|--------|------|-----|
| CADAS prevalence | 6.2% | X.X% |
| 1066 prevalence | 9.3% | X.X% |
| Gap | 3.1 pp | X.X pp |
| CADAS education (% primary+) | 92.1% | XX.X% |
| 1066 education (% primary+) | 75.3% | XX.X% |

---

*Last updated: [DATE]*
