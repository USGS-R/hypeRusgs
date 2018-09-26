# For loops + functions + if else, ifelse()

library(dplyr)

# "For loops" = repeat a chunk of code for a specific number of times
# "Functions" = bundle a code chunk to reuse
# "Ifs and elses" = control when certain code is run or not run

# Load data that we will use
DFpests <- read.csv("Webinar-9-26-2018/data/pesticide_data.csv", 
                    sep=",", header=TRUE, na.strings=c(""))
# x <- DFpests
# x <- select(x, -LAT, -LONG)
# x <- x[, 1:100]
# x <- sample_n(x, 500)
# write.csv(x, "Webinar-9-26-2018/data/pesticide_data.csv", row.names = FALSE)
# Looping ---------------------------------

# for loops =================================

# basic for loop structure
for(i in 1:3) {
  print(i)
}

aquifers <- levels(DFpests$PrincipalAquifer)
for(aqu in aquifers) {
  # Get a timeseries plot for each Aquifer for Atrazine
  plot_data <- DFpests %>% 
    filter(PrincipalAquifer == aqu) %>% 
    select(DATES, P65065)
  plot(plot_data, main = aqu, sub = "Atrazine")
}

# lapply, sapply =================================

# basic examples of vectorized looping

lapply(1:10, function(x) x*2) # returns a list
sapply(1:10, function(x) x*2) # "simplified lapply" returns vector

# Could also write these using {}
lapply(1:10, function(x) {
  x*2
})

# You can also pass in other variables to use
some_constant <- 10
lapply(1:10, function(x, constant) {
  x*2+constant
}, constant = some_constant)

# lapply example: read in multiple datasets

# 1. Programmatically get file names
avail_files <- list.files('Webinar-9-26-2018/data/', full.names = TRUE)
df_filenames <- avail_files[grep('gwl_2018', avail_files)]

# 2. Use lapply to load in each data frame
all_dfs_list <- lapply(df_filenames, function(fn) {
  read.csv(fn, colClasses = c("site_no" = "character"), stringsAsFactors = FALSE)
})

# 3. Now, use do.call and dplyr::bind_rows to get one dataframe
gwl_df <- do.call(bind_rows, all_dfs_list)

# Functions --------------------------------- 

# I like to use functions for things I know I am going to repeat a lot,
#   such as unit conversions, plots, etc.
# Writing and using functions can help keep your main analysis script 
#   a little cleaner and save you from scripts that are 1000+ lines long
# I typically suggest keeping functions in their own separate files so 
#   you can load and use them only when you need to.

# basic function structure
function_name <- function(function_arg1, function_arg2) {
  # Function code
  x <- function_arg1 + function_arg2
  
  # Function output (can only be one object - use lists to get dfs, vectos, etc out)
  return(x)
}

# We usually name the functions using an [action_descriptor], such as 
#   "get_gwdata" or "remove_badvalues".
# To use the function, it must be in your environment. So, you can just 
#   execute the lines of code for your function or use the functions 
#   `source` to load it from a file.

# Now, you can use your function just like you would functions from base R 
#   or other packages.
function_name(1,2)

# I will go through an example of taking code and converting to a function
#   using my solution to the pesticide summary code.

# Code control structures ---------------------------------

# if {} else {} =================================

# Basic structure
if (TRUE) { # or FALSE
  # do this
} else {
  # do this code chunk
}

# You can put any logical statement in the parentheses. It just needs to evaluate
#   to a single TRUE or FALSE value.

# Example: You want to skip a step when your data has missing values.
x <- DFpests$P65064

# This would not work
is.na(x) # returns more than one T/F value
# This would work
any(is.na(x)) # returns only one T/F value

if(any(is.na(DFpests$P65064))) {
  print("Dataset contains missing values. Moving to next step.")
} else {
  print("Executing model for this dataset.")
}

# ifelse() =================================

# Vectorized - good to use in dplyr::mutate situations. If you start nesting 
#   a lot of them with dplyr::mutate, consider using dplyr::case_when().

x <- ifelse(TRUE, yes = 6, no = NA)
y <- ifelse(FALSE, yes = 6, no = NA)

# Use with dplyr::mutate
DFpests_newcol <- DFpests %>% 
  mutate(new_col = ifelse(!is.na(R65064),
                          yes = "Below Detection Limit",
                          no = NA))

# More examples with this when we go over pesticide summary code (see PestsSummary_lcarr.R)
