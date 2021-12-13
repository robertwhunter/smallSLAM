library(tidyverse)
library(stringr)

fn_add_ext <- function(
  fn_base,
  extension,
  base_from = "T",
  base_to = "C"
) {
  fn_out <- case_when(
#   extension == "uniq_index" ~ paste0(fn_base, "_slam_uniq.index"),
#   extension == "uniq_TC" ~ paste0(fn_base, "_slam_uniq.", base_from, base_to, ".csv"),
    extension == "families" ~ paste0(fn_base, "_slam_families", base_from, base_to, ".csv"),
    extension == "parents" ~ paste0(fn_base, "_slam_parents.", base_from, base_to, ".index.csv"),
#   extension == "parents_TC_fastq" ~ paste0(fn_base, "_slam_parents.", base_from, base_to, ".dummy.fq"),
#   extension == "mapped" ~ paste0(fn_base, "_slam_mapped.bam"),
    extension == "slam_summary" ~ paste0(fn_base, "_slam_summary.csv")
  )
  fn_out %>% return()
}

fn_strip_ext <- function(
  fn_full
) {
  fn_root <- sub("\\_slam_*.*", "", fn_full)
  fn_root %>% return()
}

fn_strip_all <- function(
  fn_full
) {
  fn_root <- sub("\\..*", "", fn_full)
  fn_root %>% return()
}

fn_getbases <- function(
  fn
) {
  fn %>% 
    gsub(".*_parents.", "", .) %>% 
    gsub(".*_uniq.", "", .) %>% 
    gsub("*.index.csv", "", .) %>% 
    gsub("*.csv", "", .) -> bases_string
  
  list(
    base_from = substring(bases_string,1,1), 
    base_to = substring(bases_string,2,2)
    ) %>% return()
}
