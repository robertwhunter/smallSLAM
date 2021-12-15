library(ggplot2)
library(cowplot)
library(ggsci)
library(RColorBrewer)

# define palettes

palette_RWH1 <- c("red", "blue", "green", "orange", "darkgrey", "lightblue", "purple", "black")
palette_RWH2 <- c("red", "blue", "darkgreen", "purple", "black", "pink", "orange", "lightblue", "lightgreen")
palette_biotypes <- c("DarkGrey", "LightGrey", "Pink", "LightGreen", "DarkBlue", "Yellow", "Purple", "Orange", "DarkGreen", "DodgerBlue", "Red")

sc_RWH_highlights <- scale_color_manual(values = c("red", "lightgrey"))

sc_RWH1 <- scale_colour_brewer(palette = "Paired")
sf_RWH1 <- scale_fill_brewer(palette = "Paired")

sc_RWH2 <- scale_colour_brewer(palette = "Spectral")
sf_RWH2 <- scale_fill_brewer(palette = "Spectral")

sc_RWH3 <- scale_colour_locuszoom()
sf_RWH3 <- scale_fill_locuszoom()

sf_RWH4 <- scale_fill_viridis_c(option = "magma", direction = -1, limits = c(0, 0.1))
sf_RWH4L <- scale_fill_viridis_c(option = "magma", direction = -1, trans = "log", breaks = c(0.00001, 0.0001, 0.001, 0.01, 0.1))

sc_RWH5 <- scale_colour_viridis_c(option = "magma", direction = -1)
sc_RWH5_fixed <- scale_colour_viridis_c(option = "magma", limits=c(0,0.1), direction = -1)
sc_RWH5L <- scale_colour_viridis_c(option = "magma", direction = -1, trans = "log", breaks = c(0.00001, 0.0001, 0.001, 0.01), na.value = "green")
sc_RWH5L_fixed <- scale_colour_viridis_c(option = "magma", direction = -1, trans = "log", breaks = c(0.00001, 0.0001, 0.001, 0.01), limits = c(1e-6, 1e-1), na.value = "green")

sf_RWH5 <- scale_fill_viridis_c(option = "magma", direction = -1)
sf_RWH5L <- scale_fill_viridis_c(option = "magma", direction = -1, trans = "log", breaks = c(1,10,100,1000,10000,100000))




# define themes for ggplot2 graphs
theme_RWH <- function() {
  theme_minimal (base_size = 20, base_family = "Arial") +
    theme (
      panel.grid.major = element_line("grey", 0.1, 1), 
      panel.grid.minor = element_line("grey", 0.1, 2), 
      axis.line = element_line("darkgrey", 0.5, 0), 
      axis.text.x = element_text(size = rel(0.9), margin=margin(10,0,0,0)), 
      axis.text.y = element_text(size = rel(0.9), margin=margin(0,0,0,10)), 
      strip.text = element_text(colour = "black", size = rel(0.6), face="bold"),
      plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.title = element_text(size = rel(0.6), face="bold"),
      legend.text = element_text(size = rel(0.6)),
      legend.key.height=unit(2,"line")
    )
}

theme_RWH2 <- function() {
  # theme_minimal (base_size = 20, base_family = "Avenir") +
  theme_minimal (base_size = 20, base_family = "Arial") +
    theme (
      panel.grid.major = element_line("grey", 0.1, 0), 
      panel.grid.minor = element_line("grey", 0.1, 0), 
      axis.line = element_line("black", 1, 1), 
      axis.text.x = element_text(size = rel(0.9), margin=margin(10,0,0,0)), 
      axis.text.y = element_text(size = rel(0.9), margin=margin(0,0,0,10)), 
      strip.text = element_text(colour = "black", size = rel(0.6), face="bold"),
      plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.title = element_text(size = rel(0.6), face="bold"),
      legend.text = element_text(size = rel(0.6)),
      legend.key.height=unit(2,"line")
    )
}

theme_RWH_horizontal <- function() {
  theme_RWH() +
    theme (
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_line("grey", 0.1, 1), 
      panel.grid.minor.y = element_line("grey", 0.1, 2), 
      axis.line.y = element_blank(), 
      axis.line.x = element_line("black", 0.5, 1)
    )
}

theme_RWH_vertical <- function() {
  theme_RWH() +
    theme (
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_line("grey", 0.1, 1), 
      panel.grid.minor.x = element_line("grey", 0.1, 2), 
      axis.line.x = element_blank(), 
      axis.line.y = element_line("black", 0.5, 1)
    )
}


theme_RWH_LabChip <- function() {
  theme_RWH() +
    theme (
      panel.grid.major = element_line("pink", 0.1, 1), 
      panel.grid.minor = element_line("pink", 0.1, 2), 
      axis.line = element_line("darkgrey", 0.5, 0), 
      axis.text.x = element_text(size = rel(0.6)), 
      axis.text.y = element_text(size = rel(0.6)) 
    )
}

# theme_RWH_KM <- function() {
#   theme_minimal (base_size = 20, base_family = "Arial") +
#     theme (
#       panel.grid.major = element_line("grey", 0.1, 1), 
#       panel.grid.minor = element_line("grey", 0.1, 2), 
#       axis.line = element_line("darkgrey", 0.5, 0), 
#       axis.text.x = element_text(size = rel(0.9), margin=margin(10,0,0,0)), 
#       axis.text.y = element_text(size = rel(0.9), margin=margin(0,0,0,10)), 
#       strip.text = element_text(colour = "black", size = rel(0.6), face="bold"),
#       plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
#       legend.background = element_blank(),
#       legend.key = element_blank(),
#       legend.title = element_text(size = rel(0.6), face="bold"),
#       legend.text = element_text(size = rel(0.6)),
#       legend.key.height=unit(2,"line")
#     )
# }

theme_RWH_KM <- function() {
  # theme_minimal (base_size = 20, base_family = "Avenir") +
  theme_minimal (base_size = 28, base_family = "Arial") +
    theme (
      panel.grid.minor.x = element_blank(),  
      panel.grid.major.x = element_blank(),  
      panel.grid.minor.y = element_blank(),  
      panel.grid.major.y = element_line("grey", 0.2, 2),  
      axis.line = element_line("black", 0.5, 1), 
      axis.text.x = element_text(size = 24, margin=margin(10,0,0,0), color = "black"), 
      axis.title.x = element_text(size = 28, color = "black", face = "bold"),
      axis.text.y = element_text(size = 24, margin=margin(0,10,0,0), color = "black"), 
      axis.title.y = element_text(size = 28, margin=margin(0,0,0,0), color = "black", face = "bold", vjust = 0),
      strip.text = element_text(colour = "black", size = rel(1.0), face="bold"),
      plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.title = element_text(size = rel(0.6), face="bold"),
      legend.text = element_text(size = rel(0.4)),
      legend.key.height=unit(2,"line")
    )
}

theme_RWH_KM_table <- function() {
  # theme_minimal (base_size = 12, base_family = "Avenir") +
  theme_minimal (base_size = 16, base_family = "Arial") +
    theme (
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      axis.line = element_blank(), 
      axis.text.x = element_blank(), 
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text.y = element_text(size = 12, margin=margin(0,0,0,10)), 
      title = element_text(size = 16),
      legend.background = element_blank(),
      legend.key = element_blank()
    )
}

theme_RWH_CIF <- function() {
  # theme_minimal (base_size = 20, base_family = "Avenir") +
  theme_minimal (base_size = 20, base_family = "Arial") +
    theme (
      panel.grid.minor.x = element_blank(),  
      panel.grid.major.x = element_blank(),  
      panel.grid.minor.y = element_blank(),  
      panel.grid.major.y = element_line("grey", 0.2, 2),  
      axis.line = element_line("black", 0.5, 1), 
      axis.text.x = element_text(size = rel(1), margin=margin(10,0,0,0), color = "black"), 
      axis.title.x = element_text(size = rel(1), color = "black", face = "bold"),
      axis.text.y = element_text(size = rel(1), margin=margin(0,10,0,0), color = "black"), 
      axis.title.y = element_text(size = rel(1), margin=margin(0,20,0,0), color = "black", face = "bold", vjust = 0),
      strip.text = element_text(colour = "black", size = rel(1.2), face="bold"),
      plot.title = element_text(colour = "black", size = rel(1.5), face="bold"),
      plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
      legend.background = element_blank(),
      legend.key = element_blank(),
      legend.title = element_text(size = rel(1.0), face="bold"),
      legend.text = element_text(size = rel(0.8)),
      legend.key.height=unit(2,"line")
    )
}

theme_RWH_HR <- function() {
  theme_minimal (base_size = 16, base_family = "Arial") + # base size previously 12
    # theme_minimal (base_size = 12, base_family = "Avenir") +
    theme (
      # panel.grid.major.x = element_line("grey", 0.2, 1),  
      # panel.grid.minor.x = element_line("grey", 0.2, 2), 
      panel.grid.major.x = element_line("grey", 0.2, 1),  
      panel.grid.minor.x = element_blank(),
      panel.grid.major.y = element_blank(), 
      panel.grid.minor.y = element_blank(), 
      axis.line = element_line("darkgrey", 0.5, 0), 
      axis.title.x = element_text(face = "bold", margin = margin(10,0,0,0), size = 16), # ditto 12
      axis.text.x = element_text(margin = margin(4,0,0,0), size = 16), # ditto 12
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      plot.margin = unit(c(0,0,0,0), "lines"), 
      legend.position = "none"
    )
}

theme_RWH_HRtable <- function() {
  theme_minimal (base_size = 32, base_family = "Arial") + # base_size previously 16
    # theme_minimal (base_size = 16, base_family = "Avenir") +
    theme (
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      panel.border = element_blank(),
      axis.text.x = element_text(colour="white"),#element_blank(),
      axis.text.y = element_blank(), 
      axis.ticks = element_line(colour="white"),#element_blank(),
      plot.margin = unit(c(0,0,0,0), "lines"),
      legend.position = "none"
    )
}

theme_RWH_biotypes <- function() {
  theme_RWH2() +
    theme(
      axis.text.x = element_text(size = rel(1.0), margin=margin(10,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(1.0), margin=margin(0,0,0,10)),
      panel.grid.major = element_line("lightgrey", 0.0, 1), 
      panel.grid.minor = element_line("lightgrey", 0.0, 1),
      axis.line.x = element_line("black", 2, 1),
      axis.ticks.x = element_line("black", 2, 1),
      axis.line.y = element_line("black", 0.5, 0),
      axis.ticks.y = element_blank(),
      legend.title = element_text(size = rel(1.0), face="bold"),
      legend.text = element_text(size = rel(1.0)),
      plot.margin = unit(c(1,1,1,1), "lines") 
    )
}

theme_RWH_TCplot <- function() {
  theme_RWH() +
    theme(
      axis.text.x = element_text(size = rel(0.5), margin=margin(10,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(0.5), margin=margin(0,0,0,10)),
      panel.grid.major = element_line("lightgrey", 0.0, 1), 
      panel.grid.minor = element_line("lightgrey", 0.0, 1), 
      #strip.text = element_text(size = rel(0.5), color = "darkgrey")#, 
      strip.text = element_blank()
    )
}

theme_RWH_heatmap <- function() {
  theme_RWH() +
    theme(
      axis.text.x = element_text(size = rel(0.5), margin=margin(10,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(0.5), margin=margin(0,0,0,10)),
      panel.grid.major = element_line("lightgrey", 0.0, 1), 
      panel.grid.minor = element_line("lightgrey", 0.0, 1), 
      #strip.text = element_text(size = rel(0.5), color = "darkgrey")#, 
      strip.text = element_blank()
    )
}

theme_RWH_TCplot_single <- function() {
  theme_RWH() +
    theme(
      axis.text.x = element_text(size = rel(1.0), margin=margin(0,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(1.0), margin=margin(0,0,0,10)),
      panel.grid.major = element_line("lightgrey", 0.0, 1), 
      panel.grid.minor = element_line("lightgrey", 0.0, 1), 
      #strip.text = element_text(size = rel(0.5), color = "darkgrey")#, 
      strip.text = element_blank()
    )
}

theme_RWH_TCplot_tiled <- function() {
  theme_RWH_TCplot_single() +
    theme(
      axis.text.x = element_text(size = rel(1.5), angle = 0),
      axis.text.y = element_text(size = rel(1.5)),
      axis.title.x = element_text(size = rel(2.0), face = "bold", margin=margin(20,0,0,0)),
      legend.text = element_text(size = rel(1.0)),
      legend.title = element_text(size = rel(1.5))
    )
}

theme_RWH_TCplot_tiled_2 <- function() {
  theme_RWH_TCplot_single() +
    theme(
      axis.text.x = element_text(size = rel(2.0), angle = 90),
      axis.text.y = element_text(size = rel(2.0)),
      legend.text = element_text(size = rel(1.0)),
      legend.title = element_text(size = rel(1.5))
    )
}

theme_RWH_TCplot_nT <- function() {
  theme_RWH() +
    theme(
      axis.text.x = element_text(size = rel(1.5), margin=margin(0,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(1.5), margin=margin(0,0,0,10)),
      legend.background = element_rect(fill = "white", color = "white"),
      legend.key = element_rect(fill = "white", color = "white"),
      legend.text = element_text(size = rel(1.5))
    )
}

theme_RWH_basic <- function() {
  theme_RWH() +
    theme(
      axis.line = element_line("black", 0.5, 1), 
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(), 
      axis.text = element_text(size = 12, margin=margin(10,0,0,0), color = "black"), 
      axis.title = element_text(size = 12, color = "black", face = "bold")
    )
}

theme_RWH_hcolumns <- function() {
  theme_RWH() +
    theme(
      axis.title = element_text(size = 16),
      axis.text = element_text(size = 12, margin=margin(10,0,0,0), color = "black"), 
      legend.background = element_rect(color = "white"),
      legend.key = element_rect(),
      legend.key.height = unit(0.8, "cm"),
      legend.text = element_text(size = 8),
      legend.position = "left"
    )
}

theme_RWH_hcolumns2 <- function() {
  theme_RWH2() +
    theme(
      axis.title = element_text(size = 16),
      axis.text = element_text(size = 16, margin=margin(10,0,0,0), color = "black"), 
      legend.background = element_rect(color = "white"),
      legend.key = element_rect(),
      legend.key.height = unit(0.8, "cm"),
      legend.text = element_text(size = 12),
      legend.position = "left"
    )
}

theme_RWH_SNPs <- function() {
  theme_RWH2() +
    theme(
      panel.grid.major.x = element_line("grey", 0.1, 2), 
      panel.grid.minor.x = element_line("grey", 0.1, 2), 
      axis.text.x = element_text(size = rel(0.5), margin=margin(0,0,0,0), angle = 90), 
      axis.title.x = element_text(margin=margin(10,0,0,0))
    )
}

theme_RWH_FACS <- function() {
  theme_RWH() +
    theme(
      title = element_text(size = 8),
      axis.text = element_text(size = 6),
      panel.grid.major = element_blank(), # element_line("darkgrey", 0.1, 1), 
      panel.grid.minor = element_blank(), # element_line("grey", 0.1, 1), 
      axis.line = element_line("black", 1, 1),
      axis.ticks = element_line("black",0.5, 1),
      #      axis.text.x = element_text(size = rel(0.9), margin=margin(10,0,0,0)), 
      #      axis.text.y = element_text(size = rel(0.9), margin=margin(0,0,0,10)), 
      #      strip.text = element_text(colour = "black", size = rel(0.6), face="bold"),
      #      plot.caption = element_text(size = rel(0.6), face="italic", hjust = 0, margin=margin(30,0,0,0)),
      #      legend.background = element_blank(),
      #      legend.key = element_blank(),
      legend.title = element_text(size = rel(0.6), face="bold"),
      legend.text = element_text(size = rel(0.2)),
      #      legend.key.height=unit(2,"line")      
    )
}

theme_RWH_FACS_annotate_x <- function(p) {
  p +
    scale_x_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      limits = c(1,10^7),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) + 
    annotation_logticks(
      sides = "b",
      colour = "lightgrey",
      size = 0.5,
      scaled = TRUE,
      base = 10, 
      #    short = unit(-0.1, "cm"),
      #     mid = unit(-0.2, "cm"),
      #     long = unit(-0.3, "cm")
    )
}

theme_RWH_FACS_annotate_y <- function(p) {
  p +
    scale_y_log10(
      breaks = scales::trans_breaks("log10", function(x) 10^x),
      limits = c(1,10^7),
      labels = scales::trans_format("log10", scales::math_format(10^.x))
    ) + 
    annotation_logticks(
      sides = "l",
      colour = "lightgrey",
      size = 0.5,
      scaled = TRUE,
      base = 10
      #      short = unit(-0.1, "cm"),
      #      mid = unit(-0.2, "cm"),
      #      long = unit(-0.3, "cm")
    )
}

theme_RWH_Crplot <- function() {
  theme_RWH() +
    theme (
      panel.grid.major = element_line("pink", 0.1, 1), 
      panel.grid.minor = element_line("pink", 0.1, 2), 
      axis.line = element_line("black", 1, 1), 
      axis.text.x = element_text(size = rel(1.0), margin = margin(0,0,0,0)), 
      axis.text.y = element_text(size = rel(1.0)),
      axis.title = element_text(size = rel(1.0))
    )
}

theme_RWH_gantt <- function() {
  theme_RWH() +
    theme (
      panel.grid.major.y = element_blank(), 
      panel.grid.minor.y = element_blank(), 
      panel.grid.major.x = element_line("DarkGrey", 0.2, 1), 
      panel.grid.minor.x = element_line("DarkGrey", 0.2, 2), 
      axis.line = element_line("black", 1, 1), 
      axis.text.x = element_text(size = rel(0.6), margin = margin(0,0,0,0), angle = 0), 
      axis.text.y = element_text(size = rel(0.6)),
      axis.title = element_text(size = rel(1.0))
    )
}


theme_RWH_mutations_plot <- function() {
  theme_RWH() +
    theme (
      panel.grid.major.y = element_blank(), 
      panel.grid.minor.y = element_blank(), 
      axis.line.y = element_blank(), 
      axis.text.y = element_blank(),
      axis.title.y = element_blank()
    )
}
