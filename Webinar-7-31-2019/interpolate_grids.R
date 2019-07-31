# Interpolate between rasters
library(raster)

grid_100 <- raster("Webinar-7-31-2019/PredictionGrids_CV_example/preds_0.5_TD100ft.tif")
grid_150 <- raster("Webinar-7-31-2019/PredictionGrids_CV_example/preds_0.5_TD150ft.tif")
grid_200 <- raster("Webinar-7-31-2019/PredictionGrids_CV_example/preds_0.5_TD200ft.tif")

known_depths <- seq(100, 200, by = 50)
interp_depths <- seq(100, 200, by = 25)


### Verifying that this works
# Found that 10 & 81 had a non-NA value:
# getValues(grid_100, row=10, nrows = 1)
x <- 10
y <- 81
known_values_to_plot <- c(grid_100[x,y], grid_150[x,y], grid_200[x,y])
plot(known_depths, known_values_to_plot, pch=16)
###

return_corresponding_grid <- function(depth) {
  # Finds the appropriate grid file based on the depth
  switch(as.character(depth),
         `100` = grid_100,
         `150` = grid_150,
         `200` = grid_200)
}

grid_interp_list <- list() # will be used to store resulting grids

# Loop through all the depths and interpolate as needed
for(depth in interp_depths) {
  
  if(depth %in% known_depths) {
    depth_interp_grid <- return_corresponding_grid(depth)
  } else {
    # linearly interpolate between the known grids
    i0 <- tail(which(depth - known_depths > 0), 1)
    d0 <- known_depths[i0] 
    d1 <- known_depths[i0 + 1] 
    
    grid0 <- return_corresponding_grid(d0) # initial known grid
    grid1 <- return_corresponding_grid(d1) # next known grid
    
    # Linear interpolation!
    depth_interp_grid <- 
      (((grid1 - grid0)/(d1 - d0))*(depth - d0)) + grid0
    
    ### Verify that this works
    # Just for plotting to see results of interpolation
    interp_g <- depth_interp_grid[x,y]
    points(depth, interp_g, pch=16, col = "red")
    ###
    
  }
  
  # Add interpolation to the list
  grid_interp_list[[sprintf("depth_%s",depth)]] <- depth_interp_grid
}

# Quick check all the grids
for(d in 1:length(grid_interp_list)) {
  raster_d <- grid_interp_list[[d]]
  # Use value at x,y to verify that the grids are changing
  plot(raster_d, main = raster_d[x,y])
}
