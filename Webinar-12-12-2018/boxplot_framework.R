boxplot_framework <- function(upper_limit, 
                              family_font = "serif",
                              lower_limit = 0, 
                              logY = FALSE, 
                              fill_var = NA,
                              fill = "lightgrey", width = 0.6){
  
  theme_USGS_box <- function(base_family = family_font, ...){
    theme_bw(base_family = base_family, ...) +
      theme(
        panel.grid = element_blank(),
        plot.title = element_text(size = 8),
        axis.ticks.length = unit(-0.05, "in"),
        axis.text.y = element_text(margin=unit(c(0.3,0.3,0.3,0.3), "cm")), 
        axis.text.x = element_text(margin=unit(c(0.3,0.3,0.3,0.3), "cm")),
        axis.ticks.x = element_blank(),
        aspect.ratio = 1,
        legend.background = element_rect(color = "black", fill = "white")
      )
  }
  
  update_geom_defaults("text", 
                       list(size = 3, 
                            family = family_font))
  
  n_fun <- function(x, lY = logY){
    return(data.frame(y = ifelse(logY, 0.95*log10(upper_limit), 0.95*upper_limit),
                      label = length(x)))
  }
  
  prettyLogs <- function(x){
    pretty_range <- range(x[x > 0])
    pretty_logs <- 10^(-10:10)
    log_index <- which(pretty_logs < pretty_range[2] & 
                         pretty_logs > pretty_range[1])
    log_index <- c(log_index[1]-1,log_index,
                   log_index[length(log_index)]+1)
    pretty_logs_new <-  pretty_logs[log_index] 
    return(pretty_logs_new)
  }
  
  fancyNumbers <- function(n){
    nNoNA <- n[!is.na(n)]
    x <-gsub(pattern = "1e",replacement = "10^",
             x = format(nNoNA, scientific = TRUE))
    exponents <- as.numeric(sapply(strsplit(x, "\\^"), function(j) j[2]))
    
    base <- ifelse(exponents == 0, "1", ifelse(exponents == 1, "10","10^"))
    exponents[base == "1" | base == "10"] <- ""
    textNums <- rep(NA, length(n))  
    textNums[!is.na(n)] <- paste0(base,exponents)
    
    textReturn <- parse(text=textNums)
    return(textReturn)
  }
  
  if(!is.na(fill_var)){
    basic_elements <- list(stat_boxplot(geom ='errorbar', width = width),
                           geom_boxplot(width = width),
                           stat_summary(fun.data = n_fun, 
                                        geom = "text", 
                                        position = position_dodge(width),
                                        hjust =0.5,
                                        aes_string(group=fill_var)),
                           expand_limits(y = lower_limit),
                           theme_USGS_box())
  } else {
    basic_elements <- list(stat_boxplot(geom ='errorbar', width = width),
                           geom_boxplot(width = width, fill = fill),
                           stat_summary(fun.data = n_fun, 
                                        geom = "text", hjust =0.5),
                           expand_limits(y = lower_limit),
                           theme_USGS_box())
  }
  
  if(logY){
    return(c(basic_elements,
             scale_y_log10(limits = c(lower_limit, upper_limit),
                           expand = expand_scale(mult = c(0, 0)),
                           labels=fancyNumbers,
                           breaks=prettyLogs),
             annotation_logticks(sides = c("rl"))))      
  } else {
    return(c(basic_elements,
             scale_y_continuous(sec.axis = dup_axis(label = NULL, 
                                                    name = NULL),
                                expand = expand_scale(mult = c(0, 0)),
                                breaks = pretty(c(lower_limit,upper_limit), n = 5), 
                                limits = c(lower_limit,upper_limit))))    
  }
}
