# see PMID 32846052
# see www.ebi.ac.uk/ebisearch/apidoc.ebi/search - for instructions on pagination

# NB this takes a very long time to run - is quicker to simply download .fasta files manually from RNAcentral

library(httr)
library(jsonlite)
library(tidyverse)


#### pull function ----

pull_fasta <- function(taxonomy, biotype, database, fn_output, dummy_run = FALSE) {
  
  # Attempt to get directly from RNACentral did not work
  # 
  # API_pull <- GET("https://www.rnacentral.org/api/v1/rna/",
  #                   path = "search",
  #                   query = list(
  #                     q = "RNA*",
  #                     entry_type = "sequence",
  #                     format = "fasta",
  #                     TAXONOMY = "\"10090\"", # mus musculus
  #                     rna_type = "\"Y RNA\""))
  
  
  #### First pull list of genes through EBI ----
  
  EBI_pull_url_stem_short <- "https://www.ebi.ac.uk/ebisearch/ws/rest/rnacentral?query=RNA%20AND%20"
  
  EBI_pull_url_stem_short %>% 
    paste0("TAXONOMY:%22", taxonomy, "%22") %>% 
    paste0("%20AND%20") %>% 
    paste0("rna_type:%22", biotype, "%22") %>%
    paste0("%20AND%20") %>%
    paste0("expert_db:%22", database, "%22") %>%
    paste0("&fields=description,rna_type&format=json") -> EBI_pull_url_stem #format=idlist"
  
  
  # first count number of hits
  EBI_pull_url_stem %>% 
    paste0("&size=0") %>% 
    GET() -> EBI_pull
  
  EBI_pull_json <- EBI_pull$content %>% rawToChar() %>% fromJSON()
  hitCount <- EBI_pull_json$hitCount
  
  block_size <- 15 # cannot increase beyond 15 (as maximum 15 lines returned)
  
  if (dummy_run == FALSE) {n_blocks <- hitCount/block_size}
  if (dummy_run == TRUE) {n_blocks <- 2}
  
  i <- 1
  
  
  # then pull in all data
  
  EBI_unnest <- function(df) {
    df[1:2] -> df_L
    df$fields -> df_R
    cbind(df_L, df_R)
  }
  
  EBI_pull_url_stem %>% 
    paste0("&size=", block_size, "&start=", 0) %>% 
    GET() -> EBI_pull_1
  EBI_pull_json_1 <- EBI_pull_1$content %>% rawToChar() %>% fromJSON()
  EBI_pull_df <- EBI_pull_json_1$entries %>% as_tibble() %>% EBI_unnest()
  
  if (n_blocks >= 2) {
    for (i in 2:n_blocks) {
      block_start <- ((i-1)*block_size) 
      EBI_pull_url_stem %>% 
        paste0("&size=", block_size, "&start=", block_start) %>% 
        GET() -> EBI_pull_i
      EBI_pull_json_i <- EBI_pull_i$content %>% rawToChar() %>% fromJSON()
      EBI_pull_df_i <- EBI_pull_json_i$entries %>% as_tibble() %>% EBI_unnest()
      EBI_pull_df <- rbind(EBI_pull_df, EBI_pull_df_i)
    }
  }  
  
  #### THEN NEED TO GET SEQUENCE DATA FROM RNACENTRAL API ----
  
  # first convert strings into format recognised by RNA central
  EBI_pull_df %>%
    mutate(id = gsub("_", "/", id)) -> EBI_pull_df
  
  # then pull data - this takes a long time
  stem <- "https://www.rnacentral.org/api/v1/rna/"
  
  for (r in 1:nrow(EBI_pull_df)) {
    RNA_central_pull <- GET(paste0(stem, EBI_pull_df$id[r]))
    JSON_r <- RNA_central_pull$content %>% rawToChar() %>% fromJSON()
    paste0(
      ">", JSON_r$rnacentral_id, " ", JSON_r$description, "\n", 
      JSON_r$sequence, "\n") %>% 
      write_file(path = paste0(fn_output, ".fa"), append = TRUE)
  }
}


#### get data ----

# may need to first setwd

# read in index
df_index <- read_csv("RNA_biotypes_source.csv") %>% filter(source == "RNAcentral")


# get all data

for (r in 1:nrow(df_index)) {

  taxonomy <- df_index[r,]$TAXONOMY
  database <- df_index[r,]$expert_db
  fn_output <- df_index[r,]$string
  biotype <- df_index[r,]$rna_type
  
  pull_fasta(taxonomy, biotype, database, fn_output, dummy_run = TRUE)
}
