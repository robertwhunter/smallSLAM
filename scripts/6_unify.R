source("/home/rhunter3/smallSLAM_scripts/0_setup_minimal.R")
args = commandArgs(trailingOnly = TRUE)

csv_dir <- args[1]
csv_list <- list.files(path = csv_dir, pattern = "*_summary*")


get_df <- function(df_fn, df_dir) {
  
  df <- read.csv(paste0(df_dir, df_fn)) 
  df_name <- sub(pattern="_summary.csv", replacement="", df_fn)
  
  df <- df %>% select(sequence, parent_n_T, biotype, gene, family_cpm, theta_TC)
  colnames(df)[which(names(df) == "family_cpm")] <- paste0("family_cpm_", df_name)
  colnames(df)[which(names(df) == "theta_TC")] <- paste0("theta_", df_name)

  return(df)
}

df1 <- get_df(csv_list[1], csv_dir)

for (n in 2:length(csv_list)) {
  dfn <- get_df(csv_list[n], csv_dir)
  df1 <- full_join(df1, dfn)
}

df1 %>% write.csv(file = paste0(csv_dir,"Unified_summary.csv"), row.names = FALSE)
