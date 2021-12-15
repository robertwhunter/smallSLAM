library(tidyverse)
library(stringr)

fn_add_ext <- function(
  fn_base,
  extension,
  base_from = "T",
  base_to = "C"
) {
  fn_out <- case_when(
    extension == "families" ~ paste0(fn_base, "_slam_families_", base_from, base_to, ".csv"),
    extension == "parents" ~ paste0(fn_base, "_slam_parents_", base_from, base_to, ".index.csv"),
    extension == "summary" ~ paste0(fn_base, "_scount.csv")
  )
  fn_out %>% return()
}

fn_strip_ext <- function(
  fn_full
) {
  fn_root <- sub("\\.fastq.trim.uniq*.*", "", fn_full)
  fn_root <- sub("\\_slam_*.*", "", fn_root)
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
    gsub(".*_families_", "", .) %>% 
    gsub(".*_parents_", "", .) %>% 
    gsub("*.csv", "", .) -> bases_string
  
  list(
    base_from = substring(bases_string,1,1), 
    base_to = substring(bases_string,2,2)
    ) %>% return()
}
