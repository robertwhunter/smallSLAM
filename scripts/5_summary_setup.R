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

  write.csv(df_counts, file=sub(pattern=".fastq.trim.uniq_slam_parents.TC.index.csv", replacement="_summary.csv", fn_counts), row.names = FALSE)

}

