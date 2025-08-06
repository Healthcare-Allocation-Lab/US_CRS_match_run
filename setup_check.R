# US-CRS Match Run Analysis - Setup Verification Script
# Run this script to verify your environment is properly configured

cat("US-CRS Match Run Analysis - Environment Setup Check\n")
cat("=====================================================\n\n")

# Check 1: Working directory
cat("1. Checking working directory...\n")
wd <- getwd()
cat("   Current directory:", wd, "\n")

# Check if we're in the right project
if (grepl("US_CRS_match_run", wd)) {
  cat("   ✓ Working directory appears correct\n")
} else {
  cat("   ⚠ Warning: Make sure you're in the US_CRS_match_run directory\n")
}

# Check 2: renv activation
cat("\n2. Checking renv activation...\n")
lib_paths <- .libPaths()
cat("   Library paths:", lib_paths[1], "\n")

if (grepl("renv", lib_paths[1])) {
  cat("   ✓ renv is active - using project-specific library\n")
} else {
  cat("   ⚠ renv may not be active - trying to activate...\n")
  tryCatch({
    source("renv/activate.R")
    cat("   ✓ renv activated successfully\n")
  }, error = function(e) {
    cat("   ✗ Could not activate renv:", e$message, "\n")
    cat("   Please run: source('renv/activate.R')\n")
  })
}

# Check 3: Required files
cat("\n3. Checking required files...\n")
required_files <- c(".Rprofile", "renv.lock", "renv/activate.R", "CLAUDE.md", "uscrs_allocation.md")

for (file in required_files) {
  if (file.exists(file)) {
    cat("   ✓", file, "\n")
  } else {
    cat("   ✗ Missing:", file, "\n")
  }
}

# Check 4: Package availability
cat("\n4. Checking essential packages...\n")
essential_packages <- c("tidyverse", "haven", "lubridate", "furrr", "rmarkdown")

packages_status <- data.frame(
  package = essential_packages,
  installed = sapply(essential_packages, function(pkg) {
    system.file(package = pkg) != ""
  }),
  stringsAsFactors = FALSE
)

for (i in 1:nrow(packages_status)) {
  pkg <- packages_status$package[i]
  if (packages_status$installed[i]) {
    cat("   ✓", pkg, "\n")
  } else {
    cat("   ✗ Missing:", pkg, "\n")
  }
}

missing_packages <- packages_status$package[!packages_status$installed]

# Check 5: Package versions (if packages are available)
if (length(missing_packages) == 0) {
  cat("\n5. Package versions:\n")
  for (pkg in essential_packages) {
    tryCatch({
      version <- as.character(packageVersion(pkg))
      cat("   ", pkg, ":", version, "\n")
    }, error = function(e) {
      cat("   ", pkg, ": version check failed\n")
    })
  }
} else {
  cat("\n5. Skipping version check - missing packages detected\n")
}

# Summary and recommendations
cat("\n", strrep("=", 50), "\n", sep="")
cat("SETUP SUMMARY\n")
cat(strrep("=", 50), "\n")

if (length(missing_packages) == 0) {
  cat("✓ Environment setup appears complete!\n")
  cat("\nNext steps:\n")
  cat("1. Place SRTR data files in the 'data/' directory\n")
  cat("2. Review uscrs_allocation.md for allocation specifications\n") 
  cat("3. Run analysis scripts in the 'code/' directory\n")
} else {
  cat("⚠ Setup incomplete - missing packages detected\n")
  cat("\nTo fix:\n")
  cat("1. Make sure renv is active: source('renv/activate.R')\n")
  cat("2. Install missing packages: renv::restore()\n")
  cat("3. Re-run this setup check: source('setup_check.R')\n")
}

cat("\nFor detailed setup instructions, see README.md and renv_setup.md\n")