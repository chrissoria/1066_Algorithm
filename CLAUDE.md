# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a research project implementing the **10/66 Dementia Classification Algorithm** across three datasets: 10/66 (original study), HRS ADAMS, and CADAS. The algorithm combines cognitive tests, interviews, and informant reports to identify dementia using logistic regression with fixed coefficients from Prince et al. (2003).

**Key Reference:** https://bmcpublichealth.biomedcentral.com/articles/10.1186/1471-2458-8-219

## Languages & Tools

- **Stata (.do files)** - Primary implementation language for all algorithm computations
- **Python (Jupyter Notebooks)** - Visualization in ADAMS/plots/
- **SPSS** - Alternative implementation in 10_66/spss/

## Repository Structure

```
10_66/          # Original 10/66 study implementation
ADAMS/          # HRS ADAMS dataset replication and validation
CADAS/          # CADAS (Cuban/Dominican) dataset implementation
```

Each dataset folder contains:
- `do/` - Stata scripts
- `logs/` - Execution logs
- `mapping/` - Variable mapping CSVs for cross-dataset harmonization

## Algorithm Components

The dementia classification uses four main scores:

1. **COGSCORE** - Cognitive performance composite (name recall, object identification, animal naming, word recall, paper folding, story recall)
2. **RELSCORE** - Informant-reported functional abilities (weighted for missing items)
3. **RECALL** - CERAD 10-word delayed recall (0-10)
4. **GMSDIAG** - Clinical assessment categorization

**Classification:** Probability > 0.25591 threshold → dementia positive

## Key Stata Scripts

**10_66:**
- `Full_Algo_Computation.do` - Main algorithm implementation

**ADAMS:**
- `read.do` - Data preparation and merge
- `hrs1066_adams_reproduced.do` - Main replication
- `within_1066_comparison.do` - Sensitivity analysis

**CADAS:**
- `cadas_1066_reproduced.do` - Main replication
- `generating_coeffs_from_1066.do` - Coefficient extraction from training data
- `cadas_1066_sensitivity.do` - Tests 5 model variants (quintile binning, weighted relscore, binary relscore)

## Path Configuration

All do-files use a user-configurable path system at the top:
```stata
local user "Chris"
local Chris "/Users/chrissoria/Documents/Research/CADAS_1066/1066"
local path = cond("`user'" == "Chris", "`Chris'", "`Will'")
cd "`path'"
```

## Running Stata Scripts

Execute do-files from Stata:
```stata
do "10_66/do/Full_Algo_Computation.do"
do "ADAMS/do/hrs1066_adams_reproduced.do"
do "CADAS/do/cadas_1066_reproduced.do"
```

## Variable Mapping

Cross-dataset variable mappings are maintained in CSV files:
- `ADAMS/mapping/full_detailed_mapping.csv` - 10/66 → ADAMS variable mapping
- `CADAS/mapping/full_mapping.csv` - 10/66 → CADAS variable mapping

These handle differences in variable names, response scales, and recoding rules across datasets.

## Configurable Options in Do-Files

Common toggles at the top of scripts:
- `drop_missing_from_relscore` - Exclude incomplete informant responses
- `drop_physical_disability` - Filter physical disability cases
- `impute_recall` - Impute delayed recall from immediate recall
- `wave` - Select data wave (1 or 2)
