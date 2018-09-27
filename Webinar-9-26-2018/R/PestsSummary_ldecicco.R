# Laura DeCicco found a way to completely avoid for loops by using tidyr::extract()
# We didn't go over this 9/26/2018 but Lindsay brought it up. This should be covered
# at the next webinar, 10/31/2018.

library(tidyr)
library(dplyr)

# Load data
pest_codes <- read.csv("Webinar-9-26-2018/data/pest_codes.csv",
                       colClasses = "character")

DFpests <- read.csv("Webinar-9-26-2018/data/pesticide_data.csv", 
                    stringsAsFactors = FALSE)

DFpests_final <- gather(DFpests, parameter, value, 
                  -c(PrincipalAquifer, SuCode, State, STAID, DATES, NAWQA_ID))  %>%
  # the "parameter" columns splits into "value_type" and "pcode"
  # R = remark code, P = parameter value
  extract(parameter, c("value_type","pcode"), "(R|P)(.*)") %>% 
  spread(value_type, value) %>%
  mutate(h = case_when(
    is.na(R) & !is.na(P) ~ 100, # if there is not an R code but there is a value, use 100
    R =="<" & !is.na(P) ~ 0, # if the value exists and is below detection limit, use 0
    is.na(P) ~ as.numeric(NA), # otherwise use NA for no value, or 100 for an existing value
    TRUE ~ 100)) %>%
  gather(variable, value, -pcode, 
         -c(PrincipalAquifer, SuCode, State, STAID, DATES, NAWQA_ID)) %>%
  unite(variable_pcode, variable, pcode, sep = "") %>%
  spread(variable_pcode, value)

# Get columns back into the appropriate data type (they all end up as chr)
DFpests_final <- DFpests_final %>% 
  mutate_if(grepl("\\d{5}_h|P", names(.)), as.numeric) %>%
  mutate_if(grepl("\\d{5}_R", names(.)), funs(factor(., levels = c("<", "E"))))

# Reorder columns so that it goes low pcodes to high with R, P, h for each
rph_names <- names(DFpests_final)[grep("\\d{5}$", names(DFpests_final))] # just R, P, h columns
# First, reorder so R is first and h is last
rph_names <- rph_names[order(rph_names, decreasing = TRUE)]
# Next, get just the codes and order low to high
just_codes <- gsub("[a-z|A-Z]", "", rph_names) # drop letters for sorting purposes
rph_names <- rph_names[order(just_codes)]

non_rph_names <- names(DFpests_final)[!grepl("\\d{5}$", names(DFpests_final))]
col_names <- c(non_rph_names, rph_names)
DFpests_final <- select(DFpests_final, col_names)
