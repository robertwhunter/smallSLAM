library(tidyverse)

df_index <- read_csv("RNA_biotypes_source.csv") 
for (r in 1:nrow(df_index)) df_index[r,] %>% write_csv(paste0("RNA_biotypes_source_split_",r,".csv"))