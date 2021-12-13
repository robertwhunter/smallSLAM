source("/home/rhunter3/smallSLAM_scripts/0_setup_minimal.R")
source("/home/rhunter3/smallSLAM_scripts/3_parents_setup.R")

args = commandArgs(trailingOnly = TRUE)

families_to_parents(
    fn_families = args[1],
#   base_from = "T",
#   base_to = "C",
    base_from = fn_getbases(args[1])$base_from,
    base_to = fn_getbases(args[1])$base_to,
    SNP_threshold = 0.1
  )


