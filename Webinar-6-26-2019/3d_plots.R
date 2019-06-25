# 3-D plots

library(raster)
library(plotly)
library(ggplot2)
library(rayshader) # might need to install with `devtools::install_github("tylermorganwall/rayshader")`

##### Load surface elevation data #####
surface <- raster("Webinar-6-26-2019/foxcanyon_aq/w001001.adf")

# As data.frame for ggplot2
surface_plot_ready <- as.data.frame(as(surface, "SpatialPixelsDataFrame"))

# As matrix for plotly and rayshader
surface_matrix <- matrix(raster::extract(surface,raster::extent(surface),buffer=1000),
                         nrow=ncol(surface),ncol=nrow(surface))

# Create a 2D surface elevation plot
surface_ggplot <- ggplot(surface_plot_ready,
                         aes(x=x, y=y, fill = w001001)) +
  geom_raster() +
  coord_equal() +
  theme_minimal()

##### Make a plotly plot locally #####

surface_plotly <- plot_ly(z = ~surface_matrix, type = "surface")

# Export the plotly file
# FYI, "saveWidget" doesn't work when saving anywhere but the current working directory
# See the following for workarounds:
#   1. Code to wrap around the filepath: https://stackoverflow.com/a/45206860
#   2. A custom fix function: https://github.com/ramnathv/htmlwidgets/issues/299
htmlwidgets::saveWidget(as_widget(surface_plotly), "plotly_example.html")

# Can also take an existing ggplot and convert to plotly
ggplotly(surface_ggplot)

##### Alternatives to plotly #####

# You can get 3D elevation plots using the package rayshader & ggplot
# See https://github.com/tylermorganwall/rayshader for more information

# Take the 2D surface plot and convert to 3D
plot_gg(surface_ggplot, width = 5, height = 5, scale = 250, 
        zoom = 0.7, theta=10, phi=30, windowsize = c(800,800))

# This clears the 3d plotting device
rgl::clear3d()

# Can do a surface plot this way too:
zscale <- 50
ambmat <- ambient_shade(surface_matrix, zscale = zscale)
raymat <- ray_shade(surface_matrix, zscale = zscale, lambert = TRUE)

surface_matrix %>%
  sphere_shade(texture = "imhof1") %>%
  add_shadow(ambmat) %>%
  add_shadow(raymat) %>%
  plot_3d(surface_matrix, zscale = zscale, 
          # Position the initial view perspective
          fov = 0, theta = -100, phi = 30, zoom = 0.5)

# Make a 360 view movie of the current 3d surface
render_movie("Webinar-6-26-2019/foxcanyon.mp4")

# This clears the 3d plotting device
rgl::clear3d()
