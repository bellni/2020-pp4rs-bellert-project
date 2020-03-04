#' prepare_data.R
#'
#' contributors: @bellni
#'
#' Read data, clean data, create variables for analysis
#'

# Libraries
#rm(list = ls())
library("optparse")
library("readr")
library("dplyr")
library("survival")

 # CLI parsing
option_list = list(
    make_option(c("-d", "--data"),
                type = "character",
                default = NULL,
                help = "csv to extract data from",
                metavar = "character"),
	make_option(c("-o", "--out"),
                type = "character",
                default = "out.csv",
                help = "csv to save data to [default = %default]",
                metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("A csv must be provided", call. = FALSE)
}

# Read in data as csv
#data_input = read_delim("~/documents/courses/pp4rs/playground/2020-pp4rs-bellert-project/input/20190305_duration_struc_all.csv", ";")
df <- read_delim(opt$data,
                 ";")


# Change variable names
df = rename(df,
            nr_firms_in_cartel = nrFirmsInCartel,
            detection_after_death = detectionafterdeath,
            leniency_after_death = leniencyafterdeath,
            start_to_detection = starttodetection,
            death_to_detection = deathtodetection,
            detection_to_reformation = detectiontoreformation,
            death_to_reformation = deathtoreformation,
            detect_and_death = detectanddeath,
            nr_times_caught = nTimesCaught,
            start_to_death = starttodeath,
            industry_id = industry)

# Change date to years
# add enddate
# Generate variable for all detected cases
simulation_start = 1960
days_in_year = 365
variable.names(df)
df = mutate(df,
            startdate = startdate + simulation_start,
            dissolvedate = ifelse(dissolvedate > 0, dissolvedate + simulation_start, 0),
            founddate = ifelse(founddate > 0, founddate + simulation_start, 0),
            enddate = startdate + start_to_death/days_in_year,
            detected_all = detected + leniency + detection_after_death + leniency_after_death
)

# Generate variables for industries
industry_names = c("agriculture", "mining", "fooddrinks", "textile", "chemicals", "plastics", "metal", 
                   "electricity", "construction", "tradehotels", "transport", "banking", "communications", 
                   "publicservice")
df$industry_name = industry_names[(df$industry_id)]
  
# sort variables
df = df %>%
  select(industry_id, nr_firms_in_cartel, startdate, dissolvedate, founddate, enddate, start_to_death, everything())

# Save data
print("saving output")
#write_delim(df, opt$out, ";")
write_csv(df, opt$out)