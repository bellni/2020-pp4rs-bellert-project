#' caught_cartels.R
#'
#' contributors: @bellni
#'
#' Figure representing the relation between length of cartel and number of times caught
#'

# Libraries
library(optparse)
library(readr)
library(ggplot2)
library(zoo)
library(dplyr)

 # CLI parsing
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "a data set to work on",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.pdf",
                help = "pdf to save figure to [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("A data set must be provided", call. = FALSE)
}

# Load data
df <- read_csv(opt$data) 

# Create Figure
plt <- ggplot(data = df) + 
  geom_point(aes(x = start_to_death,
                 y = nr_times_caught,
                 shape = as.logical(detected_all),
                )
  ) +
  scale_shape(solid = FALSE) +
    xlab("Length of cartel") +
    ylab("Number of times caught") +
    ggtitle("Caught Cartels") +
    theme_classic() +
    theme(legend.position = "none",
          plot.title = element_text(hjust = 0.5))

ggsave(opt$out, plt)