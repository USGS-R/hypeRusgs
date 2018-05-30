# Example processing steps

# 1. Add a column for the aquifer zone based on the depth of the well.
# 2. Aggregate landuse into categories of interest.
# 3. Change landuse values to NA for categories that are past the sample's date.
# 4. Save an intermediate data file so you can easily start from aggregated data for next steps.

# Example of dplyr functions
# See https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf

library(dplyr)
library(tidyr)

gw_data <- fread('Webinar-5-30-2018/raw_data/sample_gw_data.txt',
                 colClasses = c(SITE_NO = "character")) %>% 
  mutate(DATES = as.Date(DATES))

##### Step 1: Add aquifer zone to data #####

# Determine the cutoff for shallow vs deep aquifer

  # First, find median well depth for public supply wells.
  # Use filter to get only public supply data, then calculate the median.
  public_supply_data <- gw_data %>% filter(WATER_USE_1_CD == "e")
  e_med_depth <- median(public_supply_data$WELL_DEPTH_VA, na.rm = TRUE)
  
  # Second, find median well depth for domestic wells.
  # Use filter to get only domestic data, then calculate the median.
  domestic_data <- gw_data %>% filter(WATER_USE_1_CD == "c")
  c_med_depth <- median(domestic_data$WELL_DEPTH_VA, na.rm = TRUE)
  
  # Based on this data, a good cutoff for the shallow vs deep is 190 feet
  # (can average the two medians to get that)
  aq_dividing_depth <- signif(mean(c(e_med_depth, c_med_depth)), digits = 2)
  aq_dividing_depth

# Now use the cutoff value with mutate to add a new column

  gw_data <- gw_data %>% 
    mutate(Aquifer_Zone = case_when(
      WELL_DEPTH_VA <= aq_dividing_depth ~ "shallow",
      WELL_DEPTH_VA > aq_dividing_depth ~ "deep"
    ))
  
  head(gw_data)
  unique(gw_data$Aquifer_Zone)
  
##### Step 2/3: Aggregate landuse columns & insert NAs #####

# Reshape data to be long using `tidyr::gather`
# Separate the year from the landuse category
gw_data_long <- gw_data %>% 
  gather(key = Landuse_category, value = Landuse_value, contains("LU")) %>%
  separate(Landuse_category, c("Landuse_year", "Landuse_category"), "_") 
head(gw_data_long)

# Spread data back out so that each category is a column (year remains a separate column)
# Then, create new aggregated columns
gw_data_aggr <- gw_data_long %>% 
  spread(key = Landuse_category, value = Landuse_value) %>% 
  mutate(developed = LU21 + LU22 + LU23 + LU24 + LU25 + LU26 + LU27,
         semideveloped = LU31 + LU32 + LU33,
         agricultural = LU43 + LU44 + LU45, # LU46 doesn't exist in this dataset
         lowusage = LU50 + LU60) %>% 
  select(-starts_with("LU")) # now remove unaggregated columns
head(gw_data_aggr)

# Gather one more time to insert missing values when the landuse year
#   is earlier than the sample year
gw_data_corrected_lu <- gw_data_aggr %>% 
  gather(Landuse_aggr, Landuse_aggr_value, one_of("developed", "semideveloped", 
                                                  "agricultural", "lowusage")) %>% 
  mutate(Landuse_aggr_value = ifelse(format(DATES, "%Y") < Landuse_year,
                                     yes = NA, no = Landuse_aggr_value))
head(gw_data_corrected_lu)

# As a final step, spread back out so that the year + aggregated landuse columns are headers
gw_data_lu <- gw_data_corrected_lu %>% 
  unite(Landuse_aggr_yr, Landuse_year, Landuse_aggr) %>% 
  spread(key = Landuse_aggr_yr, value = Landuse_aggr_value)
head(gw_data_lu)

##### You could do it all in one chain #####
gw_data_lu2 <- gw_data %>% 
  gather(key = Landuse_category, value = Landuse_value, contains("LU")) %>%
  separate(Landuse_category, c("Landuse_year", "Landuse_category"), "_") %>% 
  spread(key = Landuse_category, value = Landuse_value) %>% 
  mutate(developed = LU21 + LU22 + LU23 + LU24 + LU25 + LU26 + LU27,
         semideveloped = LU31 + LU32 + LU33,
         agricultural = LU43 + LU44 + LU45, # LU46 doesn't exist in this dataset
         lowusage = LU50 + LU60) %>% 
  select(-starts_with("LU")) %>% 
  gather(Landuse_aggr, Landuse_aggr_value, one_of("developed", "semideveloped", 
                                                  "agricultural", "lowusage")) %>% 
  mutate(Landuse_aggr_value = ifelse(format(DATES, "%Y") < Landuse_year,
                                     yes = NA, no = Landuse_aggr_value)) %>% 
  unite(Landuse_aggr_yr, Landuse_year, Landuse_aggr) %>% 
  spread(key = Landuse_aggr_yr, value = Landuse_aggr_value)
  
# Just to sanity check that they are the exact same:
identical(gw_data_lu, gw_data_lu2)

##### Step 4: Save cleaned up data ##### 

# Saving as rds so I can easily read it in later with column classes still intact
saveRDS(gw_data_lu, "Webinar-5-30-2018/cache_data/sample_gw_data_AggrLanduse.rds")
