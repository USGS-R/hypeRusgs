# Spatial data

# Questions being answered from our GitHub issues
# Issues: 
#   - https://github.com/USGS-R/hypeRusgs/issues/15
#   - https://github.com/USGS-R/hypeRusgs/issues/20
# 1. Joining data values with spatial data from a shapefile.
# 2. Writing shapefiles from R for use in ArcGIS.
# 3. Reviewing data associated with spatial features in R (not having to open ArcGIS).
# 4. Using ggmap background maps now that Google requires API key.

library(sf)
library(maps)
library(dplyr)
library(ggplot2)
library(mapview)
library(tmaptools)
library(ggmap)

# Highly recommend these resources:
# https://cran.r-project.org/doc/contrib/intro-spatial-rl.pdf
# https://r-spatial.github.io/sf/index.html

##### Load and plot a shapefile #####

parks_shp <- st_read("Webinar-5-1-2019/data/nps_parks_data/ne_10m_parks_and_protected_lands_area.shp")
summary(parks_shp)

# Plot the whole shape and you end up getting a plot for each factor column in the data
plot(parks_shp)

# Extract just the geometry
parks_geom <- st_geometry(parks_shp)
plot(parks_geom)

# This includes parks in Alaska and Hawaii

# First, get a map of US
# Get CONUS map data as geometry to reproject & plot
us_spatial <- maps::map("world", "us", plot = FALSE, fill = TRUE)
us_sf <- st_as_sf(us_spatial)
us_geom <- st_geometry(us_sf)
plot(us_geom)

# Now, reproject both
proj_str <- "+proj=lcc +lat_1=43.26666666666667 +lat_2=42.06666666666667 +lat_0=41.5 +lon_0=-93.5 +x_0=1500000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

us_geom_proj <- st_transform(us_geom, crs = proj_str)
parks_geom_proj <- st_transform(parks_geom, crs = proj_str)

# Example of plotting in base R
plot(us_geom_proj)
plot(parks_geom_proj, add=TRUE, fill=TRUE, col="forestgreen", border=NA)

##### Joining data to spatial data

# state shapefile
state_sf <- st_read("Webinar-5-1-2019/data/state_shp/state.shp")

# get state data (from built-in dataset in R, see `data()`)
state_df <- data.frame(state.x77)
state_df$State <- tolower(rownames(state_df))

# Join data with our sf object using `dplyr::left_join`
state_data_sf <- left_join(state_sf, state_df, by = c("ID" = "State"))
plot(state_data_sf) # see all the data plotted

# Now we can export as a shapefile for use in ArcGIS
st_write(state_data_sf, "Webinar-5-1-2019/data/state_shp/state_data.shp")

# Using ggplot to create a plot
ggplot() + 
  geom_sf(data = state_data_sf,
          aes(fill = Life.Exp)) +
  # Using a theme with no axes or grids
  theme_void() + 
  # Turn off graticules (need to do this after you add the geoms)
  coord_sf(datum = NA)

# Use ggsave to save this ggplot, which is static
?ggsave

# Using mapview to create an easy interactive map
# Converts to projection needed for mapview
# Click on the regions to see the data associated with it.
mapview(state_data_sf, zcol = "Life.Exp")

##### Google Maps API Key needed for ggmap
# You need an API key to get the Google Maps background maps in ggmap
# However, we can't really get that (plus a memo from 2013 requires special
#   permission to use the Google Maps API)
# So, here is a work around to at least get the stamen background maps using
#   the package `tmaptools` with `ggmap`

bbox <- geocode_OSM("Denver, Colorado")$bbox # from tmaptools
bbox_formatted <- rbind(as.numeric(paste(bbox)))
ggmap(get_stamenmap(bbox_formatted, zoom = 11))
ggmap(get_stamenmap(bbox_formatted, zoom = 11, maptype="toner"))
ggmap(get_stamenmap(bbox_formatted, zoom = 11, maptype="watercolor"))
