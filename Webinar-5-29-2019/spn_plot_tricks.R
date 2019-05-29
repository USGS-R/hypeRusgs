# Publication / SPN specifications for plots

library(ggplot2)

# First just setting up a generic ggplot
# Use data that is already built into R
island_df <- data.frame(Country = names(islands)[1:10], Area = islands[1:10])
island_plot <- ggplot(island_df, aes(x = Country, y = Area)) +
  geom_point() + 
  theme_bw()
island_plot

##### Superscripts, subscripts, special chars #####

# Use bquote to setup a formula
# Good blog about it: https://www.r-bloggers.com/math-notation-for-r-plot-titles-expression-and-bquote/
?bquote

# Constants go in quotes
# Variables you are using need to be preceded by `.`
# Symbols (math notation) are unquoted
# Find math notations in ?plotmath

island_plot + ylab(bquote('Area '('mi '^ 2) )) # superscript
island_plot + xlab(bquote('Country'[10])) # subscript
island_plot + ggtitle(bquote('Area by Country '[gamma])) # special character as subscript

##### Tick mark placement #####

# Pointing in but labels are off now
island_plot + theme(axis.ticks.length = unit(-0.15, "cm")) 

# Move labels away from edge
island_plot + theme(axis.text.x = element_text(margin = unit(rep(0.35, 4), "cm")),
                    axis.text.y = element_text(margin = unit(rep(0.35, 4), "cm")))

# Combine
island_plot + theme(axis.ticks.length = unit(-0.15, "cm"),
                    axis.text.x = element_text(margin = unit(rep(0.35, 4), "cm")),
                    axis.text.y = element_text(margin = unit(rep(0.35, 4), "cm")))

# Axis tick intervals
# Great blog on this: http://www.sthda.com/english/wiki/ggplot2-axis-ticks-a-guide-to-customize-tick-marks-and-labels
island_plot + scale_y_continuous(
  breaks = seq(0, 20000, by = 5000), # specify major breaks
  minor_breaks = seq(1250, 20000, by = 1250), # specify minor breaks
  labels = scales::comma, # specify function used to make labels nice
  limits = c(0, 20000), # set y limits
  expand = c(0,0) # remove space above/below axis limits
) 

##### Fonts #####

# Use "serif" to get something close to USGS font
island_plot + theme(text = element_text(family = "serif"))

# Other fonts exist, but you might need to add them
library(showtext) # to get Google fonts
font_add_google("Poppins", "Poppins")
font_add_google("Roboto", "Roboto")
font_add_google("Roboto", "Roboto")

# See fonts available
font_families()

## automatically use showtext for new devices
showtext_auto() 

# Use `windows()` to open in device outside of RStudio b/c showtext 
# doesn't work well in RStudio device

windows() 
island_plot + theme(text = element_text(family = "Poppins"))

windows()
island_plot + theme(text = element_text(family = "Roboto"))

# Great answer on StackOverflow about this: https://stackoverflow.com/a/51906008

##### Putting it all together

# Superscripts
# Ticks in
# Set minor/major breaks
# Similar USGS font

ggplot(island_df, aes(x = Country, y = Area)) +
  geom_point() + 
  ylab(bquote('Area '('mi '^ 2) )) + # superscript
  scale_y_continuous(
    breaks = seq(0, 20000, by = 5000), # specify major breaks
    minor_breaks = seq(1250, 20000, by = 1250), # specify minor breaks
    labels = scales::comma, # specify function used to make labels nice
    limits = c(0, 20000), # set y limits
    expand = c(0,0) # remove space above/below axis limits
  ) +
  theme_bw() + 
  theme(
    # Adjust ticks to point in
    axis.ticks.length = unit(-0.15, "cm"),
    axis.text.x = element_text(margin = unit(rep(0.35, 4), "cm")),
    axis.text.y = element_text(margin = unit(rep(0.35, 4), "cm"))
    )
