
# Install reticulate
if( !require(reticulate) ) {
  install.packages("reticulate")
}

# Load reticulate
library(reticulate)

# List current python environments
conda_list()

# Create a new environemnt called 'test_ppscore'
conda_create(envname = "test_ppscore")

# Install the ppscore package and its dependencies using pip into the test_ppscore environment.
# Requirements are listed here: https://github.com/8080labs/ppscore/blob/master/requirements.txt
conda_install(envname = "test_ppscore", packages = "pandas", pip = TRUE)
conda_install(envname = "test_ppscore", packages = "scikit-learn", pip = TRUE)
conda_install(envname = "test_ppscore", packages = "ppscore", pip = TRUE)

# Check if the new environment is now listed
conda_list()

# Make sure to use the just prepared environment
use_condaenv("test_ppscore")

# Import the ppscore Python module in your R session
pps <- import(module = "ppscore")


pps$

  
  