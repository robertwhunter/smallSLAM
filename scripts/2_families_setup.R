####################################################################
####### DEFINE FUNCTIONS ###########################################
####################################################################
#
#
#### 2) unique_to_families ----
#
# take top read and find all potential daughter reaads  
# make one dataframe with only this family    
# make one dataframe with all except this family (for subsequent rounds)  
# within the family, record as "nth-order" child and proportion of parent
# iterate until no reads left  

unique_to_families <- function(
  fn_unique,
  base_from = "T",
  base_to = "C",
  threshold_parent = 100
) {

  # import .uniq.index file
  df_unique <- read.csv(fn_unique, header = TRUE, stringsAsFactors = FALSE)
  df_unique %>% mutate(
    length = nchar(sequence)
  ) -> df_unique
  df_unique$rank <- as.numeric(df_unique$rank)
  df_unique$count <- as.numeric(df_unique$count)
  df_unique$length <- as.numeric(df_unique$length)
  total_reads <- sum(df_unique$count)
  
  # set up
  `%ni%` = Negate(`%in%`)
  i <- 0
  keep_looping <- TRUE
  df_out <- data.frame(
    sequence = character(),
    rank = numeric(),
    count = numeric(),
    length = numeric(),
    family = numeric(),
    child_order= numeric(),
    fam_size = numeric()
  )
  
  ## START LOOP
  ## iterative approach to finding and counting children
  ## ensure starting with a dataframe that is ordered by number of reads (so most abundant read first)  
  ## assumes that each child can have only one parent (giving priority to the most abundant parent)
  ## assumes that a child cannot be more abundant than its parent
  #
  #
  
  while (keep_looping == TRUE) {
    # start loop
    i <- i + 1
    
    # identify children of top-most read
    parent_i <- df_unique$sequence[1] %>% as.character()
    haystack_i <- df_unique$sequence %>% as.character()
    children_i <- find_children(parent_i, haystack_i, base_from, base_to)

    # exit loop if at threshold number of reads or end of file    
    if (df_unique$count[1] < threshold_parent | length(children_i) == nrow(df_unique)) {keep_looping <- FALSE}
    
    # partition into current family and the remainder (for next iteration)
    df_unique %>% dplyr::filter(sequence %in% children_i) -> family_i
    df_unique %>% dplyr::filter(sequence %ni% children_i) -> df_unique
    
    # count up children
    family_total <- family_i$count %>% sum()
    parent <- family_i$sequence[1]
    
    family_i %>% mutate(
      family = i,
      prop_parent = count / family_total,
      parent_n_base_from = str_count(parent_i, base_from),
      child_order = mapply(function(x,y) sum(x!=y),strsplit(as.character(sequence),""),strsplit(as.character(parent),"")),
      fam_size = nrow(family_i)
    ) -> family_i
    
    # return family
    df_out <- rbind(df_out, family_i)
  }

  #
  #
  ## END LOOP
  
  # write out
  colnames(df_out)[which(names(df_out) == "parent_n_base_from")] <- paste0("parent_n_", base_from)
  df_out$reads <- c(total_reads)
  
  df_out %>% write.table(
    file = fn_unique %>% fn_strip_ext() %>% fn_add_ext(extension = "families_TC", base_from, base_to),
    row.names = FALSE,
    col.names = TRUE,
    sep = ",",
    quote = FALSE
  )
}

# sub-function to generate search string to find children
make_children <- function(parent, 
                         base_from, 
                         base_to
) {
  alternate_bases <- paste0("[", base_from, base_to, "]")
  sequence_as_list <- strsplit(parent, "")[[1]]
  gsub(base_from, alternate_bases, sequence_as_list) %>% paste(collapse = "") %>% return()
}

# sub-function to find children of a parent read
find_children <- function(parent, 
                         haystack, 
                         base_from, 
                         base_to
) {
  
  needles <- make_children(parent, base_from, base_to)
  children_positions <- grep(needles, haystack)            # find potential children
  children <- haystack[children_positions]
  children <- children[nchar(children) == nchar(parent)]   # ensure children are same length as parent
  children %>% return()
}


