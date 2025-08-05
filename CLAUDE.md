# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project performs a counterfactual match run analysis comparing the current US heart allocation system (6-status therapy-based) with a proposed US-CRS (Candidate Risk Score) continuous scoring system. The analysis uses 2024 SRTR heart match run data to simulate outcomes under different allocation policies.

**Key Research Question**: How would heart allocation outcomes change if we used continuous US-CRS scores (0-50 scale) instead of the categorical 6-status system?

## Core Architecture

### Data Structure
- **Match Run Data**: `data/ptr_hr_20240101_20241231_pub.sas7bdat` - 2024 SRTR heart match run data
- **US-CRS Mapping**: US-CRS scores map to status categories:
  - Status 1: US-CRS ≥49
  - Status 2: US-CRS 40-49  
  - Status 3: US-CRS 30-39
  - Status 4: US-CRS 20-29
  - Status 5: US-CRS 10-19
  - Status 6: US-CRS 0-9

### Current vs Proposed Allocation
- **Status Quo Policy** (described in `references/heart_allocation_sequence.pdf`): Therapy-based 6-status system with geographic circles
- **Proposed Policy**: US-CRS continuous score system maintaining same geographic allocation sequence

### Analysis Pipeline
1. **US-CRS Score Generation** (`code/US_CRS_data_prep.Rmd`): Calculate time-varying US-CRS scores for candidates
2. **Match Run Processing** (`code/match_run_data_prep.Rmd`): Process SRTR match run data, map US-CRS scores to candidates, visualize current allocation patterns
3. **Counterfactual Analysis**: Re-run match runs using US-CRS scores instead of therapy-based status following `uscrs_allocation.md` specifications

### Key Data Fields (from PTR Heart File Format)
- `PX_ID`: Patient identifier
- `DONOR_ID`: Unique donor identifier
- `PTR_SEQUENCE_NUM`: Ranking position in match run
- `PTR_STAT_CD`: Current medical urgency status (2110=Status 1, 2120=Status 2, etc.)
- `PTR_DISTANCE`: Distance in nautical miles from donor to candidate center
- `MATCH_SUBMIT_DT`: Match run timestamp

## Development Commands

### R Environment Setup
```r
# Load essential libraries
library(tidyverse)
library(haven)      # For reading SRTR SAS files  
library(lubridate)  # For date handling
library(here)       # For file path management
```

### Data Loading
```r
# Read SRTR match run data
match_run <- read_sas(here("data", "ptr_hr_20240101_20241231_pub.sas7bdat"))

# Filter to heart-only match runs
heart_only_match_run <- match_run %>%
  filter(MATCH_ORG == "HR") %>%
  arrange(DONOR_ID, PTR_SEQUENCE_NUM)
```

### Key Analysis Functions
```r
# Map US-CRS scores for candidates at match run date
us_crs_mapper <- function(patient_id, match_date){
  # Returns list(us_crs_score, prob_surv_6wk) for tie-breaking
}

# Visualize match run for a specific donor
visualize_mr <- function(donor_id){
  heart_only_match_run %>%
    filter(DONOR_ID == donor_id) %>%
    ggplot(aes(x = PTR_SEQUENCE_NUM, y = PTR_DISTANCE, color = status)) +
    geom_point() + 
    labs(x = "sequence number", y = "distance (NM)")
}

# Blood type compatibility for allocation
is_blood_compatible <- function(donor_abo, candidate_abo){
  # Returns "primary", "secondary", or "incompatible"
}
```

## File Organization

### Core Analysis (`code/`)
- Primary analysis scripts for US-CRS score calculation and match run processing
- **CRITICAL: DO NOT attempt to read SAS7BDAT files during code development** - these are large SRTR data files that should only be loaded when actually running analyses

### Allocation Framework (`uscrs_allocation.md`)
- Complete specification of all 68 US-CRS based allocation classifications
- Maps Table 6-7 heart allocation sequence to US-CRS status definitions
- Defines tie-breaking rules using raw probability scores (prob_surv_6wk)
- Blood type compatibility and distance category definitions

### Mapping Tables (`mapping_tables/`)
- `us_crs_mapping_2019_2021.csv`: Maps raw survival probabilities to 50-point US-CRS scale

### Templates (`templates/`)
- Generic SRTR analysis templates for common survival analysis patterns
- `data_prep_waitlist.rmd`: Waitlist data preparation with survival time calculations
- `main_analyses.Rmd`: Common survival analysis methods (Cox, competing risks, etc.)
- `data_prep_post_tx.Rmd`: Post-transplant outcome analysis

### Reference Materials (`references/`)
- US-CRS validation paper (Zhang et al. JAMA 2024)
- `heart_allocation_sequence.pdf`: Detailed documentation of current OPTN heart allocation policy and geographic distribution
- US-CRS distribution visualization

### Data Processing Notes
- The project handles complex SRTR data structures including multiple registrations, concurrent listings, and time-varying covariates
- Uses discrete-time survival analysis framework for US-CRS score application
- Requires careful handling of transplant center identifiers and geographic distances
- Parallel processing with `furrr` package for efficient US-CRS mapping across 550k+ observations
- Time-varying US-CRS scores must align with match run submission dates for accurate counterfactual analysis

## Common SRTR Analysis Patterns

### Survival Analysis Setup
```r
# Define survival outcomes
data <- data %>%
  mutate(
    survival_time = pmin(transplant_time, death_time, removal_time, na.rm = TRUE),
    status = case_when(
      survival_time == death_time ~ 2,
      survival_time == transplant_time ~ 1,
      TRUE ~ 0  # censored
    )
  )
```

### Competing Risk Analysis
```r
library(cmprsk)
crr(Surv(survival_time, status) ~ cov1 + cov2, data = data)
```

## Important Constraints

- **Data Privacy**: All SRTR data must remain on secure systems - never commit data files
- **Geographic Allocation**: Must preserve OPTN geographic allocation sequence (500NM, 1000NM, 1500NM, 2500NM, Nation) as detailed in heart_allocation_sequence.pdf
- **Time-Varying Scores**: US-CRS scores change over time, requiring careful temporal alignment with match run dates
- **Development Safety**: Never attempt to load SAS7BDAT files when developing or debugging code - work with simulated or sample data structures instead