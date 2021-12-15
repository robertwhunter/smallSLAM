## PULL DATA ----

QCget_readcounts <- function(fn) {
  
  list_qc <- fromJSON(fn)
  
  list_qc$report_plot_data$fastqc_sequence_counts_plot[["samples"]]  -> l1
  list_qc$report_plot_data$fastqc_sequence_counts_plot[["datasets"]][[1]] %>% unnest(data) -> df
  
  df$sample <- rep(l1[1,],2)
  colnames(df) <- c("duplication", "reads", "sample")
  
  return(df)
  
}


QCget_length_distribution <- function(fn) {
  
  list_qc <- fromJSON(fn)
  
  list_qc$report_plot_data$fastqc_sequence_length_distribution_plot[["datasets"]][[1]] %>% unnest(data) -> df1
  df1$data -> df2
  df <- cbind(df1, df2)
  df %>% rename("size" = `1`, "abundance" = `2`) %>% select(name, size, abundance) -> df
  
  return(df)
  
}


QCreshape_length_distribution <- function(df) {
  df %>% 
    pivot_wider(names_from = size, values_from = abundance) %>% 
    rowwise() %>% 
    mutate(total = sum(c_across(-name))) %>% 
    ungroup() %>% 
    pivot_longer(cols = `16`:`50`, names_to = "size", values_to = "abundance") %>% 
    mutate(perc = abundance / total) -> df
  
  df$size <- df$size %>% as.character() %>% as.numeric()
  
  df %>% return()
  
}


QCget_summary <- function(fn) {
  
  # threre must be a more elegant way of unnesting this list!
  
  list_qc <- fromJSON(fn)
  
  list_samples <- list_qc$report_plot_data$fastqc_sequence_counts_plot$samples[1,]
  list_summary <- list_qc$report_general_stats_data
  
  df1 <- list_summary[[list_samples[1]]] %>% mutate(sample = list_samples[[1]])
  for (i in 2:length(list_samples)) {
    dfi <- list_summary[[list_samples[i]]] %>% mutate(sample = list_samples[[i]])
    df1 <- rbind(df1, dfi)
  }
  
  df1 %>% 
    select(sample, 
           percent_fails, 
           total_sequences, 
           percent_duplicates, 
           avg_sequence_length, 
           percent_gc) %>% 
    return()
}


#### PLOT ----

QCplot_readcounts <- function(df, df_meta){
  
  df <- left_join(df, df_meta, by = c("sample" = "library"))
  
  df$duplication <- df$duplication %>% as.factor()
  
  df %>% 
    ggplot(aes(x = sample, 
               y = reads,
               fill = group,
               alpha = duplication)) + 
    geom_bar(position = "stack", stat = "identity") +
    #   scale_y_continuous(trans = "log10") + NB CANNOT HAVE LOG TRANS HERE - IS NONSENSICAL (https://stackoverflow.com/questions/9502003/ggplot-scale-y-log10-issue)
    scale_alpha_discrete(range = c(0.3,0.8)) +
    theme_RWH_horizontal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1))
}


QCplot_length_distribution <- function(df){
  df %>%
    ggplot(aes(x = size, 
               y = abundance, 
               color = name)) + 
    geom_line() + 
    xlim(10,50) + 
    theme_RWH()
}


QCplot_length_distribution_hist <- function(df, df_meta){
  
  df <- left_join(df, df_meta, by = c("name" = "library"))
  
  df %>%
    ggplot(aes(x = size, 
               y = perc,
               fill = group)) + 
    geom_col(alpha = 0.6) + 
    xlim(10,50) + 
    facet_wrap(~name) +
    theme_RWH_horizontal()
}


QCplot_length_distribution_hist_trim <- function(df, df_meta){
  
  df <- left_join(df, df_meta, by = c("name" = "library"))
  
  df %>%
    ggplot(aes(x = size, 
               y = perc,
               fill = group)) + 
    geom_col(alpha = 0.6) + 
    scale_x_continuous(limits = c(16,26), breaks = seq(16,26,2)) + 
    facet_wrap(~name) +
    theme_RWH_horizontal() +
    theme(axis.text.x = element_text(size = 8))
}


plot_biotypes <- function(df) {
  df %>% 
    group_by(library, biotype) %>% 
    summarise(reads = sum(readsCPM), group = group[1]) %>% 
    ggplot(aes(x = library, y = reads, fill = biotype)) + 
    geom_col(position = position_fill()) +
    coord_flip() +
    facet_wrap(~group, ncol = 1, scales="free") +
    theme_RWH_vertical() 
}
