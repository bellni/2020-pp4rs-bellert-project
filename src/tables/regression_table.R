#' regression_table.R
#'
#' contributors: @bellni
#'
#' Regression Table 
#'

# Libraries
library(optparse)
library(rlist)
library(magrittr)
library(purrr)
library(stargazer)
library(tools)

# CLI parsing
option_list = list(
   make_option(c("-f", "--filepath"),
               type = "character",
               default = NULL,
               help = "A directory path where models are saved",
               metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.tex",
                help = "output file name [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$filepath)){
 print_help(opt_parser)
 stop("Input filepath must be provided", call. = FALSE)
}

# Load Files
dir_path  <- opt$filepath
file_list <- list.files(dir_path, full.names = TRUE)

# model names are from the files themselves
model_names <- basename(tools::file_path_sans_ext(file_list))

# Load into a list
data <- file_list %>%
            map(list.load) %>%
            setNames(model_names)

# Create Table
stargazer(data$ols,
          keep = c("leniencypolicy"),
          title = "Estimates of the Introduction of Leniency to Detection Rates",
          df = FALSE,
          type = "latex",
          out = opt$out
          )
