rm(list=ls())  ## remove old objects
if(!is.null(dev.list())) dev.off()  ## clear old plots

library(dplyr)
library(ggplot2)
library(data.table)
library(gridExtra)
library(ggpubr)
library(agricolae)

# Read in some data
DF <- fread("Webinar-12-12-2018/exampleDF.csv", data.table = FALSE)
str(DF)

## ANOVA of ranked Rn-222 by SuCode2
## sort and calculate the ranks of Rn-222
DF <- arrange(DF, P82303)
DF <- mutate(DF, rnkP82303=rank(P82303, na.last=NA, ties.method="average"))
# calculate ANOVA on ranks and Tukey levels
a <- aov(rnkP82303~SuCode2, data=DF)
tHSD <- TukeyHSD(a, ordered = FALSE, conf.level = 0.95)
tOrder <- HSD.test(a, "SuCode2", group=TRUE, console=TRUE) ## lists results of Tukey's test

group_labels <- tOrder[["groups"]] %>%
  tibble::rownames_to_column(var = "SuCode2")


## step by step
levs <- group_by(DF, SuCode2)
str(levs)
levs <- summarize(levs,
                  med=median(KPb210),
                  q_75  = as.numeric(quantile(KPb210, probs = 0.75)),
                  IQR = as.numeric(quantile(KPb210, probs = 0.75)) -
                    as.numeric(quantile(KPb210, probs = 0.25)),
                  upper_whisker = 10 +max(KPb210[KPb210 < (q_75 + 1.5 * IQR)]))
levs <- arrange(levs, desc(med))
levs <- left_join(levs, group_labels, by="SuCode2")
levs <- mutate(levs, SuCode2=factor(SuCode2, levels=SuCode2))

DF$SuCode2 <- factor(DF$SuCode2, levels=levels(levs$SuCode2))

## plot the results
p_base <- ggplot() +
    geom_boxplot(data = DF, aes(x=SuCode2, y=KPb210)) +
    geom_text(data = levs,
              aes(x = SuCode2, y = upper_whisker, label = groups)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5))
p_base

# if you run the boxplot_framework code, it changes the default text type to serif by default
# eps (postscript) files default to Helvetica, so you need to add serif
# see names(postscriptFonts()) for a list of other postscript fonts you can use
ggsave("Webinar-12-12-2018/KPb210_by_SuCode2.eps", width = 11, height = 4, dpi = 300, fonts = "serif")

## Might look better:
p_base2 <- ggplot() +
  geom_boxplot(data = DF, aes(x=SuCode2, y=KPb210)) +
  geom_text(data = levs,
            aes(x = SuCode2, y = -100, label = groups)) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.5))
p_base2
ggsave(p_base2, filename = "Webinar-12-12-2018/KPb210_by_SuCode2.eps", width = 11, height = 4, dpi = 300, fonts = "serif")
