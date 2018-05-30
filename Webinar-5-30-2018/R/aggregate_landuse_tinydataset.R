# Example spread/gather/etc on a much smaller dataset

library(dplyr)
library(tidyr)

df <- data.frame(
  site_no = c("site1", "site2", "site3"),
  date = c("2009-10-02", "1998-01-27", "2014-10-12"),
  `1974_LU21` = c(0, 0, 20),
  `1974_LU22` = c(10, 0, 30),
  `1974_LU43` = c(0, 50, 0),
  `1974_LU44` = c(0, 10, 20),
  `2012_LU21` = c(20, 30, 30),
  `2012_LU22` = c(20, 0, 40),
  `2012_LU43` = c(0, 40, 0),
  `2012_LU44` = c(0, 0, 20)
)

# developed = LU21 + LU_23
# agriculture = LU43 + LU44

# Need to aggregate into a column for each year for developed and agriculture
# resulting data frame:
df_desired <- data.frame(
  site_no = c("site1", "site2", "site3"),
  date = c("2009-10-02", "1998-01-27", "2014-10-12"),
  `1974_developed` = c(10, 0, 50),
  `1974_agriculture` = c(0, 60, 30),
  `2012_developed` = c(40, 30, 70),
  `2012_agriculture` = c(0, 40, 20)
)

# what I did
df_long <- df %>% 
  gather(key = Landuse_category, value = Landuse_value, contains("LU")) %>%
  separate(Landuse_category, c("Landuse_year", "Landuse_category"), "_") 

df_aggr <- df_long %>% 
  spread(key = Landuse_category, value = Landuse_value) %>% 
  mutate(developed = LU21 + LU22,
         agriculture = LU43 + LU44)

df_lu_insert_missing <- df_aggr %>% 
  mutate(YEAR = format(as.Date(date), "%Y")) %>% 
  select(-starts_with("LU")) %>% 
  gather(Landuse_aggr, Landuse_aggr_value, one_of("developed", "agriculture")) %>% 
  mutate(Landuse_year = gsub("X","",Landuse_year)) %>%
  mutate(Landuse_aggr_value = ifelse(YEAR < Landuse_year, NA, Landuse_aggr_value))

df_result <- df_lu_insert_missing %>% 
  unite(Landuse_aggr_yr, Landuse_year, Landuse_aggr) %>% 
  spread(key = Landuse_aggr_yr, value = Landuse_aggr_value)

