#### SET PATHS ----
# dir_data and dir_meta defined in .Rprofile file
dir_QC <- here(dir_data, "Trim_multiqc", "Trim_multiqc_data")
dir_scounts <- here(dir_data, "Summary")


#### READ IN DATA ----
QC_json_fn <- list.files(dir_QC, pattern = ".json", full.names = TRUE)

df_QC <- read_delim(here(dir_QC, "multiqc_general_stats.txt"), delim = "\t") 
colnames(df_QC) <- c("library", "duplicates %", "GC %", "length (mean)", "fails %", "reads")  

#df_QC2 <- read_delim(here(dir_QC, "multiqc_fastqc.txt"), delim = "\t")

fn_scounts <- list.files(dir_scounts, pattern = "_scount.csv", full.names = TRUE) %>% set_names()
fn_scounts %>% 
  purrr::map_dfr(read_csv, .id = "library") %>% 
  mutate(library = word(basename(library))) %>%  
  mutate(library = gsub("_scount.csv", "", library)) -> df_scounts

here(dir_meta, "metadata.csv") %>% 
  read_csv() %>% 
  filter(library %in% df_scounts$library) -> df_meta

source(here("analysis", "6d_meta_names_repair.R"))