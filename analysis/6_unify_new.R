library(tidyverse)
library(here)
csv_dir <- here("~/Documents/scp_INBOX")

read_all_csv <- function(csv_dir) {
  fn_list <- list.files(csv_dir, pattern = ".csv", full.names = TRUE) %>% set_names()
  
  fn_list %>% 
    purrr::map_dfr(read_csv, .id = "source") %>% 
    mutate(source = word(basename(source))) %>% 
    return()
}

read_all_csv(csv_dir) %>% 
  mutate(source = gsub("_summary", "", source)) -> df_summary
  

