render_smallSLAM <- function(fname) {

  # dir_data defined in .Rprofie
  dir_data <- paste0(dir_data_root, fname, "/")
  
  rmarkdown::render("analysis/6_analysis.Rmd",
                    output_dir = paste0(dir_data, "output/"),
                    output_file = fname,
                    params = list(
                      fname = fname,
                      dir_data = dir_data
                    ))
  
}
