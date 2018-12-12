# Making the boxplot more USGS-compliant
# copy/pasted code for functions from the boxplot plot (https://owi.usgs.gov/blog/boxplots/) into
# their own scripts so that I can use them here by sourcing.
library(cowplot)
source("Webinar-12-12-2018/TukeyBoxPlotsTestv5.R") # run tukey boxplot code
source("Webinar-12-12-2018/boxplot_framework.R") # load boxplot framework fxn (see https://owi.usgs.gov/blog/boxplots/)
source("Webinar-12-12-2018/ggplot_box_legend.R") # load boxplot legend fxn (see https://owi.usgs.gov/blog/boxplots/)

# Set an upper limit to use boxplot_framework()
first_row_text_y <- signif(max(DF$KPb210), 1)
second_row_text_y <- max(DF$KPb210) * 0.9

## plot the results
p_base_usgs <- ggplot(data = DF, aes(x=SuCode2, y=KPb210)) +
  geom_text(data = levs, aes(x = SuCode2, y = second_row_text_y, label = groups)) +
  boxplot_framework(upper_limit = first_row_text_y) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5))
p_base_usgs

# add the legend next to the plot
legend_plot <- ggplot_box_legend()
legend_plot

plot_grid(p_base_usgs, legend_plot,
          rel_widths = c(.6,.4))

ggsave("Webinar-12-12-2018/KPb210_by_SuCode2_explanation.eps", width = 11, height = 4, dpi = 300, fonts = "serif")
