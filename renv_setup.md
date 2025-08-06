# renv Setup for US-CRS Match Run Analysis

This project uses `renv` to ensure reproducible package management and consistent environments across different machines.

## What is renv?

`renv` is a package management system for R that:
- Creates isolated, project-specific package libraries
- Records exact package versions in a lockfile (`renv.lock`)
- Ensures all collaborators use identical package versions
- Prevents package conflicts between projects

## Files Created

- **`.Rprofile`**: Automatically activates renv when opening the project
- **`renv.lock`**: Records all package versions and dependencies
- **`renv/`**: Contains the project-specific package library
- **`install_packages.R`**: Script to install essential packages

## Essential Packages Installed

### Core Analysis
- **`tidyverse`**: Data manipulation, visualization (dplyr, ggplot2, etc.)
- **`haven`**: Reading SAS files (.sas7bdat)
- **`lubridate`**: Date and time handling
- **`here`**: Safe file path management

### Parallel Processing  
- **`furrr`**: Parallel versions of purrr functions
- **`future`**: Backend for parallel processing

### Reporting
- **`rmarkdown`**: R Markdown document generation
- **`knitr`**: Report compilation and code execution

### Visualization
- **`viridisLite`**: Color palettes for plots
- **`scales`**: Scaling functions for ggplot2
- **`DT`**: Interactive data tables
- **`plotly`**: Interactive plots

## Usage Instructions

### For New Users
When someone clones this repository:

1. **Open RStudio**: Open the `US_CRS_match_run.Rproj` file
2. **renv activates automatically**: The `.Rprofile` loads renv
3. **Restore packages**: Run `renv::restore()` to install all required packages

```r
# This installs all packages from renv.lock
renv::restore()
```

### For Development

#### Adding New Packages
```r
# Install new package
install.packages("new_package")

# Update lockfile to include it
renv::snapshot()
```

#### Checking Package Status
```r
# See which packages are out of sync
renv::status()

# See project dependencies
renv::dependencies()
```

#### Updating Packages
```r
# Update specific package
renv::update("package_name")

# Update all packages
renv::update()

# Snapshot after updates
renv::snapshot()
```

## Important Notes

### What's Tracked in Git
- ✅ `renv.lock` (package versions)
- ✅ `.Rprofile` (renv activation)
- ✅ `renv/activate.R` (renv bootstrap)
- ❌ `renv/library/` (actual packages - too large)
- ❌ `renv/local/` (user-specific settings)

### Data Privacy
The `.gitignore` ensures:
- SRTR data files (`.sas7bdat`, `.Rdata`) are never committed
- Only code and package specifications are tracked
- Large result files are excluded

## Project Workflow

### 1. Starting Work
```r
# Open US_CRS_match_run.Rproj in RStudio
# renv activates automatically
# All packages are available in isolated environment
```

### 2. Installing Dependencies (First Time)
```r
# If packages are missing
renv::restore()
```

### 3. Adding Analysis Packages
```r
# Example: Adding survival analysis
install.packages("survival")
install.packages("survminer")

# Save to lockfile
renv::snapshot()
```

### 4. Before Committing Changes
```r
# Check package status
renv::status()

# Update lockfile if needed
renv::snapshot()

# Commit both code and renv.lock
```

## Troubleshooting

### Package Installation Errors
```r
# Clear renv cache and reinstall
renv::purge()
renv::restore()
```

### Conflicts with System Packages
```r
# Isolate project completely
renv::isolate()
```

### Reset Environment
```r
# Nuclear option - rebuild from scratch
renv::init(force = TRUE)
```

## Benefits for This Project

1. **Reproducibility**: Exact package versions for US-CRS analysis
2. **Collaboration**: Team members get identical environments  
3. **SRTR Compliance**: No data files, only code and dependencies tracked
4. **Performance**: Parallel processing packages properly managed
5. **Future-Proofing**: Analysis remains runnable years later

## Commands Reference

```r
# Essential renv commands
renv::status()     # Check package status
renv::restore()    # Install packages from lockfile  
renv::snapshot()   # Update lockfile with current packages
renv::update()     # Update packages to latest versions
renv::clean()      # Remove unused packages
renv::dependencies() # List project dependencies
```

This setup ensures that the US-CRS match run analysis remains reproducible and that all team members can run the analysis with identical package environments.