
# Parallel computing to speed up code

# Try to avoid parallel process with web service calls.
# E.g. dataRetrieval::readNWISdata

# Difference in serial & parallel is more noticeable for bigger operations
# So, first decide if the gains from parallel code are worth the parallelization effort

# Example we use here: interpolating between daily snow rasters. We want to interpolate 
#   to get a smoother transition between each day for a gif.
# To read raster objects, you need raster & sp packages
# To create GIFs you need the animation pacakge & ImageMagick installed on your system
# You can run this code without ImageMagick - just skip any of the `saveGIF` functions

library(raster)
library(sp)
library(animation)

##### Load in rasters to use + make gif #####

# Load in daily rasters to use in interpolation (can't send .rds raster file because
#   rasters store some info in temp directories locally, so we woul be missing info)
# This step takes ~ 2min per raster. 
source("Webinar-4-3-2019/R/convert_to_raster.R") # load custom function
snow_depth0 <- convert_to_raster("Webinar-4-3-2019/data/snow_20190321.dat")
snow_depth1 <- convert_to_raster("Webinar-4-3-2019/data/snow_20190322.dat")

# This GIF gets saved in the upper folder. saveGIF doesn't work with path in file name
saveGIF({
  plot(snow_depth0, breaks = c(1, 100, 1500), col = c("lightgreen", "darkgreen"), main = "2019-03-21 00:00")
  plot(snow_depth1, breaks = c(1, 100, 1500), col = c("lightgreen", "darkgreen"), main = "2019-03-22 00:00")
}, movie.name = "animation_daily.gif")

##### Setup snow interp function #####

interp_snow <- function(snow_depth0, snow_depth1, hour) {
  (snow_depth0 * (1 / hour) + snow_depth1 * (1 / (24-hour))) / 
    (( 1 / hour) + (1 / (24-hour)))
}

##### Examples using serial patterns #####

# Interpolate the noon raster for one day
# Takes 0.11 seconds (on lplatt's computer)
system.time({
  snow_interp <- interp_snow(snow_depth0, snow_depth1, 12)
})

# Now try three hours in serial (takes about 3x as long, which is expected)
# Takes 0.30 seconds (on lplatt's computer)
hours <- c(6,12,18)
system.time({
  snow_interp1 <- interp_snow(snow_depth0, snow_depth1, hours[1])
  snow_interp2 <- interp_snow(snow_depth0, snow_depth1, hours[2])
  snow_interp3 <- interp_snow(snow_depth0, snow_depth1, hours[3])
})

# Now use loop w/ 3 hours (still serial execution, not parallel)
# Also takes 0.30 seconds (on lplatt's computer)
hours <- c(6,12,18)
snow_interp_list1 <- list()
system.time({
  for(h in hours) {
    snow_interp_list1[[h]] <- interp_snow(snow_depth0, snow_depth1, h)
  }
})

# lapply() is vectorized option
# Apply functions are not meant to be faster, but the style is similar to what is needed for parallel code
# Takes 0.28 seconds (on lplatt's computer)
hours <- c(6,12,18)
system.time({
  snow_interp_list2 <- lapply(hours, function(h) {
    interp_snow(snow_depth0, snow_depth1, h)
  })
})

# Scaling up to hours for a full day is where parallel starts to matter, but still not by much.
hours <- 1:23

# Use loop w/ 23 hours
# Takes 2.61 seconds (on lplatt's computer)
snow_interp_list3 <- list()
system.time({
  for(h in hours) {
    snow_interp_list3[[h]] <- interp_snow(snow_depth0, snow_depth1, h)
  }
})

# lapply() with 23 hours
# Takes 2.81 seconds (on lplatt's computer)
system.time({
  snow_interp_list4 <- lapply(hours, function(h) {
    interp_snow(snow_depth0, snow_depth1, h)
  })
})

##### Now parallelize! #####

# Waiting 2.81 seconds is not really a reason to parallelize, but let's use this example anyways.
# CPU - R runs on single core. Parallelizing takes advantage of more than one core

library(parallel) # Comes with R

# How many cores does your computer have?
detectCores()

# First, setup cores to use (best to leave one open for other processes)
n_cores <- detectCores() - 1

# Next, make a cluster using your cores
# If you wait too long to run your parallel code after running this line, your cluster will go away
cl <- makeCluster(n_cores)

# Now, you can do the parallel version of lapply, parLapply
# Takes 6.61 seconds for 3 (on lplatt's computer)
hours <- c(6,12,18)

# First, define what from the current global environment is needed.
# lapply and for loops look at the global environment, but parallel 
# processes need to be explicitly told what to pass through since each 
# parallel process will act like a new, clean R session
clusterExport(cl, varlist=c('interp_snow', 'snow_depth0', 'snow_depth1'))
system.time({
  snow_interp_list5 <- parLapply(cl, hours, function(h) {
    # Need libraries in parallel functions because each parallel process
    # is similar to a new environment and these are needed to handle any raster.
    library(raster)
    library(sp)
    interp_snow(snow_depth0, snow_depth1, h)
  })
})

# Turn off cluster
stopCluster(cl)

##### Try more hours with parallel #####
hours <- 1:23

# From above, for loop took 2.61 seconds (on lplatt's computer)

# This parallel version took 34 seconds (on lplatt's computer)
# This is an example of how parallelizing this particular code is not ideal. It likely
#   also has to do with lplatt's computer only have 3 cores available. A computer with
#   more cores should be able to run more parallel processes at one time.
cl <- makeCluster(n_cores)
clusterExport(cl, varlist=c('interp_snow', 'snow_depth0', 'snow_depth1'))
system.time({
  snow_interp_list6 <- parLapply(cl, hours, function(h) {
    library(raster)
    library(sp)
    interp_snow(snow_depth0, snow_depth1, h)
  })
})
stopCluster(cl)

##### Other packages for parallel #####

library(doParallel) # useful on 3 major OS (Windows, Mac, Linux)

##### doParallel example #####
# Still detect cores and make cluster using `parallel` pacakge functions

n_cores <- detectCores() - 1
cl <- makeCluster(n_cores)

# Now register cluster for doParallel
registerDoParallel(cl)

# Now run your function using `foreach` instead of parLapply
# There is slightly different syntax, especially for loading needed packages
#   and environment variables. Use `.export` arg for environment variables and 
#   `.packages` for required packages. The iterating object (`hours` in this case)
#   should be loaded first, but can be named anything (we chose `h`). The `.combine`
#   argument tells R how to bring the results of the parallel processes together
#   into one object at the end. It needs to be a function. By default results will be
#   returned in a list, which makes the output similar to parLapply. %dopar% is from 
#   the doParallel package and connects the parallel setup (defined in `foreach`) with 
#   the function call to run in parallel (`interp_snow`).

# Takes 12 seconds for 3 hours (on lplatt's computer)
hours <- c(6, 12, 18)
system.time({
  snow_interp_list7 <- foreach(h = hours,
                               .export = c('interp_snow', 'snow_depth0', 'snow_depth1'),
                               .packages = c('raster', 'sp')) %dopar% 
    interp_snow(snow_depth0, snow_depth1, h)
})

# End the cluster at the end using `parallel` package function
stopCluster(cl)

##### Make gif using results of parallel processing #####

# Now that we have run these in parallel, we can include the interpolated raster
#   into the GIF we made at the beginning. Remember, you need the `animation` package.
# This GIF gets saved in the upper folder. saveGIF doesn't work with path in file name
plot_colors <- c("lightgreen", "darkgreen")
plot_breaks <- c(1, 100, 1500)
hours <- c(6, 12, 18)
saveGIF({
  plot(snow_depth0, breaks = plot_breaks, col = plot_colors, main = "2019-03-21 00:00")
  for(hour in 1:length(snow_interp_list7)) {
    plot(snow_interp_list7[[hour]], breaks = plot_breaks, col = plot_colors, 
         main = sprintf("2019-03-21 %s:00", sprintf("%02d", hours[hour])))
  }
  plot(snow_depth1, breaks = plot_breaks, col = plot_colors, main = "2019-03-22 00:00")
}, movie.name = "animation_hourly.gif")

##### Other resources #####

# Example using EGRET package
# http://usgs-r.github.io/EGRET/articles/parallel.html

# caret modeling package + parallelization
# https://topepo.github.io/caret/parallel-processing.html

# Run parallel processes on remote resources
# HT Condor (https://research.cs.wisc.edu/htcondor/)
# Yeti (https://gitlab.cr.usgs.gov/hpc-arc/yeti-user-docs/wikis/home)
  # USGS Core Science Systems
  # Offer trainings periodically at the NTC in Denver
