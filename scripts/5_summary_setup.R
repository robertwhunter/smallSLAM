####################################################################
####### DEFINE FUNCTIONS ###########################################
####################################################################
#
#
#### 5) merge_mapping ----
#
#

merge_mapping <- function(
  fn_counts
) {

  fn_map <- sub(pattern = ".index.csv", replacement = ".index.csv.dummy.fasta.all_biotypes.tsv", fn_counts)
  
  df_counts <- read.csv(fn_counts)
  df_map <- read.delim(fn_map, sep="\t", header = TRUE, stringsAsFactors = FALSE)

  # set the mapping heirarchy (first = dominant)  
  df_map <- df_map %>% select(
    sequence = Sequence, 
    rRNA, 
    tRNA,
    miRNA,
    piRNA, 
    snoRNA, 
    snRNA, 
    vaultRNA, 
    YRNA,
    lncRNA, 
    pctranscripts, 
    genome = Genome
  )
  df_map$biotype = c("unmapped")
  df_map$gene = c(NA)
  df_map$gene <- as.character(df_map$gene)

  # assign single gene to each sequence
  for (r in 1:nrow(df_map)) {
    for (b in 12:2) {
      if (df_map[r,b] != 0) {
        df_map$biotype[r] = colnames(df_map)[b]
        df_map$gene[r] = df_map[r,b]
      }
    }
  }
  
  # merge mapping and count data
  df_map <- df_map %>% select(sequence, biotype, gene)
  df_counts <- left_join(df_counts, df_map, by = c("sequence"))
  
  df_counts <- df_counts %>% collapse_to_genes() %>% arrange(-cpm)

  df_counts %>% write.csv(
    file=fn_counts %>% fn_strip_ext() %>% fn_add_ext(extension = "summary"), 
    row.names = FALSE
    )

}


## function to collapse parent reads mapping to same gene 
collapse_to_genes <- function(df) {
  
  df %>% 
    # first ensure genes not mapped or mapped to genome don't have duplicate names
    mutate(gene = if_else(biotype %in% c("genome", "unmapped"), 
                          paste0(gene, "_", sequence),
                          gene)) %>% 
    
    # then collapse data to single genes
    mutate(theta_weight = theta*family_total) %>% 
    group_by(gene) %>% 
    summarise(
      biotype = biotype[1],
      n_parents = length(sequence),
      reads = sum(family_total),
      cpm = sum(family_cpm) %>% round(),
      cR = sum(n_conversions) / sum(total_T),
      wtheta = mean(theta_weight / reads)
    ) %>% return()
}
