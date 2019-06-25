# 3-D plots

library(raster)
library(ggplot2)
library(rayshader)

# Plotly has an offline capability, but I don't know how you 
# can get the plots without publishing publicly or having 
# an enterprise server. See https://plot.ly/r/offline/

# Load surface elevation data
surface <- raster("Webinar-6-26-2019/foxcanyon_aq/w001001.adf")

# You can get 3D elevation plots using the package rayshader & ggplot
# See https://github.com/tylermorganwall/rayshader for more information

surface_plot_ready <- as.data.frame(as(surface, "SpatialPixelsDataFrame"))
surface_ggplot <- ggplot(surface_plot_ready,
                         aes(x=x, y=y, fill = w001001)) +
  geom_raster() +
  coord_equal() +
  theme_minimal()

# Take the 2D surface plot and convert to 3D
plot_gg(surface_ggplot, width = 5, height = 5, scale = 250, 
        zoom = 0.7, theta=10, phi=30, windowsize = c(800,800))

# This clears the 3d plotting device
rgl::clear3d()

# Can do a surface plot this way too:

elmat <- matrix(raster::extract(surface,raster::extent(surface),buffer=1000),
               nrow=ncol(surface),ncol=nrow(surface))
elmat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_3d(elmat,zscale=50,fov=0,theta=-100,phi=30, zoom=0.5)

# Make a 360 view movie of the current 3d surface
render_movie("Webinar-6-26-2019/foxcanyon.mp4")

# This clears the 3d plotting device
rgl::clear3d()
