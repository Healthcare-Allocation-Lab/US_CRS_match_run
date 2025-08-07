# National US-CRS Based Heart Allocation System

This document defines a simplified national US-CRS based heart allocation system that ignores geographic distance but maintains essential prioritization rules for pediatric status, donor age groups, and ABO compatibility.

## Overview

The National US-CRS system simplifies the 172-classification framework by removing distance constraints while preserving the core allocation principles:

- **US-CRS Score Priority**: Higher scores indicate higher transplant need
- **Pediatric Protection**: Pediatric candidates prioritized for pediatric donors
- **Blood Type Compatibility**: Primary matches preferred over secondary
- **Age-Appropriate Matching**: Donor age categories maintained

## US-CRS Status Definitions

- **Status 1**: US-CRS ≥ 49 (Highest priority)
- **Status 2**: US-CRS 40-49 (High priority)  
- **Status 3**: US-CRS 30-39 (Moderate-high priority)
- **Status 4**: US-CRS 20-29 (Moderate priority)
- **Status 5**: US-CRS 10-19 (Lower priority)
- **Status 6**: US-CRS 0-9 (Lowest priority)

## Blood Type Compatibility

### Primary Matches (Preferred)
- **Donor O** → Recipient O, B
- **Donor A** → Recipient A, AB
- **Donor B** → Recipient B, AB  
- **Donor AB** → Recipient AB

### Secondary Matches (Allowed)
- **Donor O** → Recipient A, AB

## Donor Age Categories

- **Adult Donors**: ≥18 years old
- **Pediatric Donors**: <18 years old

## Candidate Categories

### Adult Candidates
- Age ≥18 years at listing
- Current status: Status 1-6 (non-pediatric codes)
- US-CRS score determines priority within each blood/donor age group

### Pediatric Candidates  
- Age <18 years at listing OR
- Current status: "Status 1A (pediatric)", "Status 1B (pediatric)", "Status 2 (pediatric)"
- Status codes: 2010, 2020, 2030

---

# National Allocation Classifications

## Table N1: Adult Donors (≥18 years) - Classes 1-12

| Class | Candidates | Blood Match | US-CRS Status | Priority Order |
|-------|------------|-------------|---------------|----------------|
| 1 | Adult US-CRS Status 1 + Pediatric Status 1A | Primary | ≥49 | Highest |
| 2 | Adult US-CRS Status 1 + Pediatric Status 1A | Secondary | ≥49 | |
| 3 | Adult US-CRS Status 2 | Primary | 40-49 | |
| 4 | Adult US-CRS Status 2 | Secondary | 40-49 | |  
| 5 | Adult US-CRS Status 3 + Pediatric Status 1B | Primary | 30-39 | |
| 6 | Adult US-CRS Status 3 + Pediatric Status 1B | Secondary | 30-39 | |
| 7 | Adult US-CRS Status 4 | Primary | 20-29 | |
| 8 | Adult US-CRS Status 4 | Secondary | 20-29 | |
| 9 | Adult US-CRS Status 5 | Primary | 10-19 | |
| 10 | Adult US-CRS Status 5 | Secondary | 10-19 | |
| 11 | Adult US-CRS Status 6 + Pediatric Status 2 | Primary | 0-9 | |
| 12 | Adult US-CRS Status 6 + Pediatric Status 2 | Secondary | 0-9 | Lowest |

## Table N2: Pediatric Donors (<18 years) - Classes 13-24

| Class | Candidates | Blood Match | US-CRS Status | Priority Order |
|-------|------------|-------------|---------------|----------------|
| 13 | **Pediatric Status 1A** | Primary | Status 1A | **Pediatric Priority** |
| 14 | **Pediatric Status 1A** | Secondary | Status 1A | |
| 15 | Adult US-CRS Status 1 | Primary | ≥49 | After pediatric |
| 16 | Adult US-CRS Status 1 | Secondary | ≥49 | |
| 17 | **Pediatric Status 1B** | Primary | Status 1B | **Pediatric Priority** |
| 18 | **Pediatric Status 1B** | Secondary | Status 1B | |
| 19 | Adult US-CRS Status 2 | Primary | 40-49 | After pediatric |
| 20 | Adult US-CRS Status 2 | Secondary | 40-49 | |
| 21 | Adult US-CRS Status 3 | Primary | 30-39 | |
| 22 | Adult US-CRS Status 3 | Secondary | 30-39 | |
| 23 | **Pediatric Status 2** | Primary | Status 2 | **Pediatric Priority** |
| 24 | **Pediatric Status 2** | Secondary | Status 2 | |

**Note**: Classes continue with Adult Status 4, 5, 6 following the same pediatric-first pattern.

---

## Allocation Logic

### Priority Ranking Algorithm

1. **Donor Age Determination**: 
   - If DON_AGE ≥ 18 → Use Table N1 (Adult Donors)
   - If DON_AGE < 18 → Use Table N2 (Pediatric Donors)

2. **Blood Type Filtering**:
   - Remove incompatible matches
   - Primary matches ranked before secondary matches

3. **Classification Assignment**:
   - Adult Donors: Assign classes 1-12 based on candidate status and blood match
   - Pediatric Donors: Assign classes 13-24+ with pediatric candidates prioritized

4. **Within-Classification Tie-Breaking**:
   - **Primary**: US-CRS Score (higher = better priority)
   - **Secondary**: Raw survival probability (lower = better priority)  
   - **Tertiary**: Waiting time (longer = better priority)

### Pediatric Priority Rules

For **pediatric donors**, the allocation prioritizes pediatric candidates:

```
Pediatric Donor → Pediatric Status 1A → Adult Status 1 → Pediatric Status 1B → Adult Status 2 → ...
```

This ensures pediatric organs preferentially go to pediatric recipients while still allowing adult access when no suitable pediatric candidates exist.

### Implementation Notes

#### Candidate Classification
```r
candidate_type <- case_when(
  str_detect(status, "pediatric") ~ "pediatric",
  PTR_STAT_CD %in% c("2010", "2020", "2030") ~ "pediatric",
  CAN_AGE_AT_LISTING < 18 ~ "pediatric",
  TRUE ~ "adult"
)
```

#### US-CRS Status Mapping
```r
uscrs_status_numeric <- case_when(
  us_crs_score >= 49 ~ 1,
  us_crs_score >= 40 & us_crs_score < 49 ~ 2,
  us_crs_score >= 30 & us_crs_score < 40 ~ 3,
  us_crs_score >= 20 & us_crs_score < 30 ~ 4,
  us_crs_score >= 10 & us_crs_score < 20 ~ 5,
  us_crs_score >= 0 & us_crs_score < 10 ~ 6,
  TRUE ~ NA_real_
)
```

#### Blood Type Compatibility
```r
blood_compatibility <- case_when(
  donor_abo == "O" & candidate_abo %in% c("O", "B") ~ "primary",
  donor_abo == "O" & candidate_abo %in% c("A", "AB") ~ "secondary", 
  donor_abo == "A" & candidate_abo %in% c("A", "AB") ~ "primary",
  donor_abo == "B" & candidate_abo %in% c("B", "AB") ~ "primary",
  donor_abo == "AB" & candidate_abo == "AB" ~ "primary",
  TRUE ~ "incompatible"
)
```

---

## Expected Impact

### Advantages of National System:
- **Simplified Implementation**: Only 24 main classifications vs 172
- **Broader Access**: No geographic restrictions maximize organ utilization
- **Maintained Priorities**: Key clinical priorities (US-CRS, pediatric status) preserved
- **Clear Logic**: Straightforward classification system

### Key Differences from Full System:
- **No Distance Penalties**: All candidates compete nationally
- **Higher Competition**: Increased candidate pool for each organ
- **Simplified Logistics**: Fewer classification rules to implement

This national system provides a streamlined approach to US-CRS based allocation while maintaining the essential clinical and ethical priorities of the full geographic system.