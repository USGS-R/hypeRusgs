# Read in & process files programmatically

library(data.table)
library(dplyr)
library(ggplot2)

# Get files to read in

files_to_read <- list.files("Webinar-5-29-2019/data", full.names = TRUE)

# Loops through each file
for(fn in files_to_read) {
  
  # Get month number from filename
  fn_end <- unlist(strsplit(fn, split = "airquality_"))[2]
  fn_mon <- as.numeric(gsub(".csv", "", fn_end))
  
  # Read in the file
  df <- fread(fn)
  
  # Remove missing ozone values
  df <- filter(df, !is.na(Ozone))
  
  # For June only, also remove solar.r missing values
  if(fn_mon == 6) {
    df <- filter(df, !is.na(Solar.R))
  }
  
  # Save plot for each
  plot_mon <- ggplot(df, aes(Day, Ozone)) + geom_point() + ggtitle(fn_mon)
  plot_fn <- sprintf("Webinar-5-29-2019/plots/airquality_plot_%s.png", fn_mon)
  ggsave(plot_fn, plot_mon, height = 4, width = 6)
}

# What if there were multiple data frames in your environment you 
# wanted to loop through?
df1
df2
df3

for(d in 1:3) {
  print(paste0("df", d))
}

df_list <- list(
  df1 = iris,
  df2 = precip,
  df3 = airquality
)

for(i in 1:length(df_list)) {
  print(names(df_list[[i]]))
}

?lapply

# similar to list.files but for environment
ls()

