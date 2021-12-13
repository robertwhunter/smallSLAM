####################################################################
####### DEFINE FUNCTIONS ###########################################
####################################################################
#
#

parents_to_genes <- function(df_parents) {
  
  df_parents %>% 
    select(sequence_parent = sequence, gene, biotype, contains("theta_")) %>% 
    pivot_longer(
      cols = contains("theta_"),
      names_to = "lib",
      names_prefix = "theta_",
      values_to = "theta"
    ) -> df_thetas_L
  
  df_parents %>% 
    select(sequence_parent = sequence, gene, biotype, contains("family_cpm_")) %>% 
    pivot_longer(
      cols = contains("family_cpm_"),
      names_to = "lib",
      names_prefix = "family_cpm_",
      values_to = "family_cpm"
    ) -> df_cpm_L
  
  df_parents_L <- left_join(df_cpm_L, df_thetas_L) %>% drop_na()
  df_parents_L <- df_parents_L %>% filter(family_cpm > 0)
  
  df_parents_L %>% 
    mutate(
      theta_weighted = theta*family_cpm
    ) %>% 
    group_by(lib, gene) %>% 
    summarise(
      biotype = biotype[1],
      no_parent_sequences_from_parents = length(unique(sequence_parent)),
      theta_weighted_sum = sum(theta_weighted),
      readsCPM = sum(family_cpm),
      gene_theta = (theta_weighted_sum/readsCPM)
    ) %>% 
    
    return()
  
}

families_to_tcounts <- function(
  df_families,
  SNP_threshold = 0.1
) {
  
  # filter out SNPs
  df_families <- df_families %>% filter(child_order == 0 | prop_parent < SNP_threshold)
  
  # get summary totals
  df_families %>% 
    mutate(
      coverage_on_Ts = count * parent_n_T, 
      count_conversions = count * child_order
    ) %>% 
    group_by(lib, gene) %>% 
    summarise(
      group = group[1],
      biotype = biotype[1],
      coverageOnTs = sum(coverage_on_Ts),
      conversionsOnTs = sum(count_conversions),
      no_parent_sequences_tcounts = length(unique(sequence_parent))
    ) %>% 
    mutate(
      conversionRate = conversionsOnTs / coverageOnTs) -> df_tcounts_small
  
  # write out
  df_tcounts_small %>% return()
  
}


#### GET PARENTS

df_parents %>% 
  select(sequence_parent = sequence, biotype, gene) %>% 
  unique() -> df_index


#### COLLAPSE PARENT SEQUENCES MAPPING TO SAME GENE

df_parents %>% 
  parents_to_genes() %>% 
  filter(biotype %ni% c("genome", "unmapped")) %>% 
  filter(lib != set_excludelibs) -> df_parents_gene


#### GET FAMILIES

names(lib_data$Families_fn) <- lib_data$Families_fn_short

lib_data$Families_fn %>%
  get_families_index(df_meta) -> df_families

df_families %>% 
  left_join(df_index) %>% 
  filter(lib != set_excludelibs) -> df_families


#### GENERATE tcounts FILE

df_families %>% 
  families_to_tcounts(SNP_threshold = 0.1) %>% 
  filter(biotype %ni% c("genome", "unmapped")) %>% 
  filter(coverageOnTs > 0) %>% 
  full_join(df_parents_gene, by = c("lib", "gene", "biotype")) -> df_tcounts

df_tcounts %>% 
  rename(library = lib, exp_group = group, gene_name = gene) -> df_tcounts
