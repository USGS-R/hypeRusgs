# Reading in data with correct classes

# setwd() and install.packages()

library(data.table)

##### Step 1: read in data #####

# Example using `fread` from data.table
# `fread` is useful for reading in large data, but can be used for any size
# Note that `fread` argument colClasses does not accept date classes as read.table does
# `fread` also allows columns to start with a number, so X is not prepended

gw_data <- fread('Webinar-5-30-2018/raw_data/sample_gw_data.txt')

##### Step 2: explore and verify data #####

# Look at data as read.table interpreted it and see if that looks correct.
str(gw_data)
summary(gw_data)

# The site numbers are being read in as numbers, which is generally not ideal since they 
#   are an identifier and not going into any calculations. We should add `colClasses` 
#   argument to coerce into character.
# Dates are not being read in as a date class, either Date (just the year, month, day) 
#   or POSIXct (year, month, day, as well as hours, minutes, seconds). Using fread, 
#   we cannot coerce to either of the date classes using colClasses and will need to
#   take care of it afterwards. For large data, you could use the `fasttime` package,
#   but we will show how to convert these without that in a different script.

##### Step 3: adjust arguments to read data correctly #####

# The SITE_NO column should be interpreted as "character" not "integer", and dates 
#   will be handled after they are read in.
gw_data <- fread('Webinar-5-30-2018/raw_data/sample_gw_data.txt',
                 colClasses = c(SITE_NO = "character"))
head(gw_data$SITE_NO)
