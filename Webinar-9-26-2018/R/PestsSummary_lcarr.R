# Pests Summary

library(tidyr)
library(dplyr)

# Load data
pest_codes <- read.csv("Webinar-9-26-2018/data/pest_codes.csv",
                       colClasses = "character")

DFpests <- read.csv("Webinar-9-26-2018/data/pesticide_data.csv", 
                    sep=",", header=TRUE, na.strings=c(""))

DFpests_unite <- DFpests
for (c in pest_codes[[1]]) {
  R_col <- paste0("R", c)
  P_col <- paste0("P", c)
  combine_col <- paste0("code_", c)
  
  DFpests_unite <- DFpests_unite %>% 
    unite_(combine_col, c(R_col, P_col), sep = "_")
}

DFpests_gathered <- gather(DFpests_unite, 
                          key = pest_code, 
                          value = R_P_values, 
                          -c(PrincipalAquifer, SuCode, State, STAID, DATES, NAWQA_ID))

DFpests_gathered_sep <- DFpests_gathered %>% 
  separate(R_P_values, c("R", "P"), sep = "_")

DFpests_hcode <- DFpests_gathered_sep %>% 
  mutate(h = case_when(
    is.na(R) & !is.na(P) ~ 100, # if there is not an R code but there is a value, use 100
    R =="<" & !is.na(P_col) ~ 0, # if the value exists and is below detection limit, use 0
    is.na(P) ~ as.numeric(NA), # otherwise use NA for no value, or 100 for an existing value
    TRUE ~ 100))

# Get back into wide format
DFpests_hcode_wide <- DFpests_hcode %>% 
  unite("R_P_h", c(R, P, h), sep = "_") %>% 
  spread(pest_code, R_P_h)

DFpests_final <- DFpests_hcode_wide
for (c in pest_codes[[1]]) {
  R_col <- paste0("R", c)
  P_col <- paste0("P", c)
  h_col <- paste0("h", c)
  combine_col <- paste0("code_", c)
  
  DFpests_final <- DFpests_final %>% 
    separate(combine_col, c(R_col, P_col, h_col), sep = "_")
}
