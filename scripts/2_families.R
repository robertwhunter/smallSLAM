source("/home/rhunter3/smallSLAM_scripts/0_setup_minimal.R")
source("/home/rhunter3/smallSLAM_scripts/2_families_setup.R")

args = commandArgs(trailingOnly = TRUE)
unique_to_families(
    fn_unique = args[1],
    base_from = "T",
    base_to = "C",
    threshold_parent = as.numeric(as.character(args[2]))
  )

