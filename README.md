# SRTR-Project-Template

This repository outlines the proper structure of a repository for an SRTR organ allocation project. It contains R scripts, data mapping tables (if relevant), and other supporting files for analyzing transplant data using the SRTR dataset.

## Repository Contents

### data_prep_post_tx.Rmd:

Example data prep cases for post-transplant analyses
Includes data cleaning, filtering, and the development of any new variables
This file is required for any project analzying post-transplant outcomes

### data_prep_waitlist.Rmd:

Example data prep cases for waitlist analyses.
Includes data cleaning, filtering, and the development of any new variables.
Includes examples of how to deal with waitlist specific issues (multiple listings, multi organ listings)
This file is required for any project analyzing waitlist outcomes

### main_analyses.Rmd:

Performs the primary statistical and survival analyses.
Includes example code for cumulative incidence functions (CIFs), competing risks regressions, Kaplan-Meier survival estimates, cox proportional hazards and mixed effects models.
This file is required for all projects.

### main_figures.Rmd:

Generates key figures for publication, such as kaplan meier curves, cumulative incidence plots, forest plots, table 1s, and strobe diagrams.
This file is required for all projects

### supplement.Rmd:

Contains supplemental analyses and additional visualizations supporting the main manuscript.
This file is required for all projects.

The mapping table csvs should be used and included in the repo of any project analyzing EPTS or KDPI.
