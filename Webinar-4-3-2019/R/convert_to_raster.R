# Load spatial file and convert to reasonably sized raster

convert_to_raster <- function(fn, crop_geom_fn = 'Webinar-4-3-2019/data/view_polygon.rds') {
  library(raster)
  library(sp)
  
  # Load in files
  crop_extent_sfcpolygon <- readRDS(crop_geom_fn)
  snow_depth <- readBin(fn, integer(), n=33554432, size=2, signed=TRUE, endian='big')
  
  # Size of SNODAS data
  n_col <- 8192
  n_row <- 4096
  
  # boundary extent for unmasked SNODAS
  x0 <- -130.516666666661
  x1 <- -62.2499999999975
  y0 <- 24.0999999999990
  y1 <- 58.2333333333310
  
  # projection of crop polygon
  proj_to_str <- "+proj=lcc +lat_1=43.26666666666667 +lat_2=42.06666666666667 +lat_0=41.5 +lon_0=-93.5 +x_0=1500000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
  
  snow_depth[snow_depth <= 0] <- 0
  snow_depth_mat <- matrix(snow_depth, nrow = n_col)
  
  # Convert to raster
  snow_raster <- raster::raster(ncol=n_col, nrow=n_row, xmn = x0, xmx = x1, ymn = y0, ymx = y1)
  snow_raster <- raster::setValues(snow_raster, snow_depth)
  
  # Add the correct projection
  # Source for WGS 84 projection: "Projecting SNODAS Data" section on https://nsidc.org/data/g02158
  raster::crs(snow_raster) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  
  # Now reproject for this visualization
  snow_raster_proj <- raster::projectRaster(snow_raster, crs = raster::crs(proj_to_str))
  
  # Now crop
  crop_extent_geom <- sf::st_sf(sf::st_geometry(crop_extent_sfcpolygon))
  snow_raster_proj_crop <- raster::crop(snow_raster_proj, crop_extent_geom)
  
  return(snow_raster_proj_crop)
}

