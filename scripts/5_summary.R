source("/home/rhunter3/smallSLAM_scripts/0_setup_minimal.R")
source("/home/rhunter3/smallSLAM_scripts/5_summary_setup.R")

args = commandArgs(trailingOnly = TRUE)

merge_mapping(
    fn_counts = args[1]
  )


