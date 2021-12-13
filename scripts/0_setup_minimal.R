library(tidyverse)
library(stringr)

fn_add_ext <- function(
  fn_base,
  extension,
  base_from = "T",
  base_to = "C"
) {
  fn_out <- case_when(
    extension == "families" ~ paste0(fn_base, "_families_", base_from, base_to, ".csv"),
    extension == "parents" ~ paste0(fn_base, "_parents_", base_from, base_to, ".index.csv"),
    extension == "summary" ~ paste0(fn_base, "_summary_", base_from, base_to, ".csv")
  )
  fn_out %>% return()
}

fn_strip_ext <- function(
  fn_full
) {
  fn_root <- sub("\\.fastq.trim.uniq*.*", "", fn_full)
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
    gsub(".*_families", "", .) %>% 
    gsub(".*_parents", "", .) %>% 
    gsub("*.csv", "", .) -> bases_string
  
  list(
    base_from = substring(bases_string,1,1), 
    base_to = substring(bases_string,2,2)
    ) %>% return()
}
