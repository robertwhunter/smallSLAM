####################################################################
####### DEFINE FUNCTIONS ###########################################
####################################################################
#
#
#### 3) families_to_parents ----
#
# write an index file, `fastp.parents.TC.index`
# write a dummy fasta file for use in mapping, `.fastp.parents.TC.fa`

families_to_parents <- function(
  fn_families,
  base_from = "T",
  base_to = "C",
  SNP_threshold = 0.1
) {
  # import file
  df_families <- read.csv(fn_families, stringsAsFactors = FALSE)
  
  # remove after
  colnames(df_families)[which(names(df_families) == "parent_n_T")] <- "parent_n_base_from"
  
  # filter out SNPs
  df_families <- df_families %>% filter(child_order == 0 | prop_parent < SNP_threshold)
  
  # get overall conversion rates
  df_families <- df_families %>% get_conversion_rates()
  
  # get summary totals
  df_families %>% group_by(family, child_order) %>% summarise(
    total = sum(count)
  ) -> df_totals
  
  df_totals %>% 
    pivot_wider(
      names_from = child_order, 
      names_prefix = "child_",
      values_from = total
      ) -> df_totals
  
  # ensure there are columns up to child_3 and replace NAs with zeros
  if (ncol(df_totals) == 2) {df_totals$`child_1` <- c(NA)}
  if (ncol(df_totals) == 3) {df_totals$`child_2` <- c(NA)}
  if (ncol(df_totals) == 4) {df_totals$`child_3` <- c(NA)}
  df_totals[is.na(df_totals)] <- 0
  
  # calculate thetas
  df_nT <- df_families %>% select(family, parent_n_base_from) %>% unique()
  df_totals <- left_join(df_totals, df_nT, by = c("family"))
  df_totals %>% mutate(
    theta = theta_by_MLE_calc(
      n_family = sum(child_0, child_1, child_2, child_3),
      n_child_1 = child_1,
      n_child_2 = child_2,
      n_child_3 = child_3,
      nT = parent_n_base_from
    )
  ) -> df_totals
  
  # reconcile with sequence to generate df_index 
  df_families %>% 
    filter(child_order == 0) %>% 
    select(family, sequence, reads, n_conversions) -> df_index
  
  df_index <- left_join(df_index, df_totals, by = c("family"))

  df_index %>% rowwise() %>% mutate(
    family_total = sum(c_across(contains("child_"))),
    total_base_from = family_total*parent_n_base_from,
    conversion_rate = n_conversions / total_base_from,
    family_cpm = (family_total/reads)*1000000
  ) -> df_index

  df_index <- df_index %>% select(-reads)
  
  df_index %>% select(
    family,
    sequence,
    contains("child_"),
    family_total,
    family_cpm,
    parent_n_base_from,
    total_base_from,
    n_conversions,
    conversion_rate,
    theta
  ) -> df_index

  colnames(df_index)[which(names(df_index) == "child_0")] <- "parent"
  colnames(df_index)[which(names(df_index) == "parent_n_base_from")] <- paste0("parent_n_", base_from)
  colnames(df_index)[which(names(df_index) == "total_base_from")] <- paste0("total_", base_from)
  
  #write out
  df_index %>% write.table(
    file = fn_families %>% fn_strip_ext() %>% fn_add_ext(extension = "parents", base_from, base_to),
    row.names = FALSE,
    col.names = TRUE,
    sep = ",",
    quote = FALSE
  )
  
}

# sub-function to estimate theta by maximum liklihood estimation, MLE (using calculus)
# adopting method of MLE from www.dlinares.org/mlebinom.html and https://rpubs.com/felixmay/MLE
theta_by_MLE_calc <- function(
  n_family,  # observed frequency: total number of family reads
  n_child_1, # observed frequency: number of 1st-order-children
  n_child_2, # observed frequency: number of 2nd-order-children
  n_child_3, # observed frequency: number of 3rd-order-children
  nT         # number of T loci (or any alternative "base_from")
) {
  var_x <- (n_child_1*1) + (n_child_2*2) + (n_child_3*3) # total number of events
  var_n <- (nT * n_family)                               # total number of trials
  theta <- var_x/var_n
  theta %>% return()
}

# sub-function to get conversion rates simply by counting
get_conversion_rates <- function(df_in) {
  df_in %>% 
    mutate(n_conversions = child_order * count) %>% 
    group_by(family) %>% 
      summarise(n_conversions = sum(n_conversions)) -> df_conversions
  df_in %>% left_join(df_conversions) %>% return()
}

