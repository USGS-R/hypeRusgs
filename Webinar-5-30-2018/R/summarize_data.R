# See data summaries

library(dplyr)

# Read in cached data from `R/clean_data`
gw_data_lu <- readRDS("Webinar-5-30-2018/cache_data/sample_gw_data_AggrLanduse.rds")

# Summarize information by choosing a certain column as the group
#   using `dplyr::group_by` and `dplyr::summarize`.

##### Find mean nitrate + nitrite concentration by water use type #####

mean_no3_no2 <- gw_data_lu %>% 
  group_by(WATER_USE_1_CD) %>% 
  summarize(mean_no3_no2 = mean(P00631, na.rm = TRUE))
mean_no3_no2

##### Include the number of missing values and censored values #####

summarize_no3_no2 <- gw_data_lu %>% 
  group_by(WATER_USE_1_CD, Aquifer_Zone) %>% 
  summarize(mean_no3_no2 = mean(P00631, na.rm = TRUE),
            num_vals = n(),
            num_censored = sum(grepl("<", R00631)),
            num_missing = sum(is.na(P00631)))
summarize_no3_no2

##### Recode values to be less cryptic #####
# In addition to the summary table, include the real name for the category using recode
nitrate_summary <- summarize_no3_no2 %>% 
  mutate(WATER_USE_NAME = recode(WATER_USE_1_CD, 
    e = "Public Supply",
    c = "Domestic",
    d = "Dewater",
    a = "Fire",
    b = "Recreation",
    .default = "Other"
  ))
nitrate_summary
