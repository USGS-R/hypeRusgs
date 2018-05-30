# Getting date class columns

library(dplyr)

gw_data <- fread('Webinar-5-30-2018/raw_data/sample_gw_data.txt',
                 colClasses = c(SITE_NO = "character"))

##### How to format dates that ARE in YYYY-mm-dd #####

# Correctly changing columns with dates to be a date class (Date or POSIXct). You could
#   leave dates as character if you didn't plan to plot or use as part of any calculation. 
#   Typically, we overwrite the existing character string column with the correct date 
#   class values using the `dplyr::mutate` function.

# This data has the DATES column as R expects (YYYY-mm-dd) and has times in a 
#   separate column. We can just coerce to the Date class since times are separate.

# dplyr::mutate creates a new column (or overwrites a column if you have name it the same)
as.Date("2010-10-01")
# gw_data <- mutate(gw_data, DATES = as.Date(DATES))
gw_data <- gw_data %>% mutate(DATES = as.Date(DATES))
str(gw_data)

##### How to format dates that ARE NOT in YYYY-mm-dd #####

# Going to show issue with opening data in excel.
#   Opened and then saved changes to the file in Excel (without actually making any 
#   changes myself). WARNING: this changes how dates appear in the text file.
gw_data_excel <- fread('Webinar-5-30-2018/raw_data/DataSample.txt',
                       colClasses = c(SITE_NO = "character"))
head(gw_data_excel$DATES)

# For the Excel example, we cannot just coerce the date column into the correct class 
#   because it is not in theformat R expects (YYYY-mm-dd), and is instead formatted how 
#   Excel stores dates (mm/dd/YYYY). We will need to manipulate it into a date class by 
#   telling R where to look for the different parts of the date. 

test_date <- gw_data_excel$DATES[1] # Extract one date value to play with
test_date
as.Date(test_date) # R expects dates to be YYYY-mm-dd, so it throws an error
?as.Date # The `format` function will help us tell R how to interpret our date
?strptime # This is the help file that has all of the correct codes for date formats
as.Date(test_date, format = "%m/%d/%Y") # Specify the format of our date using appropriate symbols

# Using `dplyr::mutate` and `as.Date`, we can convert the date column into a date class
gw_data_excel <- gw_data_excel %>% mutate(DATES = as.Date(DATES, format = "%m/%d/%Y"))
head(gw_data_excel$DATES)
