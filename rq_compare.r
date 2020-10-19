#install.packages("tidyverse")
#install.packages("reshape2")
#install.packages("PMCMRplus")
library("tidyverse")
library("effsize")
library("reshape2")
library("PMCMR")
#library("PMCMRplus")

# RQ1.A Naive Time vs Time
## Hyphotesis test
### Precision
shapiro.test(releases_bproj$time_precision)
shapiro.test(releases_bproj$range_precision)
wilcox.test(releases_bproj$range_precision, releases_bproj$time_precision, paired = TRUE)

### Recal
shapiro.test(releases_bproj$time_recall)
shapiro.test(releases_bproj$range_recall)

wilcox.test(releases_bproj$range_recall, releases_bproj$time_recall, paired = TRUE)
cliff.delta(releases_bproj$range_recall, releases_bproj$time_recall)

### F-measure
shapiro.test(releases_bproj$time_fmeasure)
shapiro.test(releases_bproj$range_fmeasure)

wilcox.test(releases_bproj$range_fmeasure, releases_bproj$time_fmeasure, paired = TRUE)
cliff.delta(releases_bproj$range_fmeasure, releases_bproj$time_fmeasure)
  
## Boxplots
releases_bproj_melted %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    scale_x_discrete(labels=c("time_naive_precision" = "naive time-based",
                              "time_precision" = "time-based",
                              "range_precision" =  "range-based")) +
    ylab("") + ylim(0,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_compare_bp_precision.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  scale_x_discrete(labels=c("time_naive_recall" = "naive time-based",
                            "time_recall" = "time-based",
                            "range_recall" =  "range-based")) +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_compare_bp_recall.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(grepl("fmeasure", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  scale_x_discrete(labels=c("time_naive_fmeasure" = "naive time-based",
                            "time_fmeasure" = "time-based",
                            "range_fmeasure" =  "range-based")) +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_compare_bp_fmeasure.png", width = 8, height = 2)


## Scatter - Strategy per project
releases_bproj %>%
  ggplot(aes(x=time_precision, y=range_precision)) +
  geom_point() +
  geom_abline() +
  xlim(0,1) + xlab("time-based") +
  ylim(0,1) + ylab("range-based") +
  theme_bw(base_size = 14)

## Scatter - Strategy per project
releases %>%
  ggplot(aes(x=time_precision, y=range_precision)) +
  geom_point() +
  geom_abline() +
  xlim(0,1) + xlab("time-based") +
  ylim(0,1) + ylab("range-based") +
  theme_bw(base_size = 18)

#
# Compare recall
#
shapiro.test(releases_bproj$time_naive_recall)
shapiro.test(releases_bproj$time_recall)
shapiro.test(releases_bproj$range_recall)
wilcox.test(releases_bproj$time_recall, releases_bproj$range_recall, paired = TRUE)
cliff.delta(releases_bproj$time_recall, releases_bproj$range_recall)

releases_bproj_melted %>%
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  scale_x_discrete(labels=c("time_naive_recall" = "naive time-based",
                            "time_recall" = "time-based",
                            "range_recall" =  "range-based")) +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw() +
  ggsave("../paper/figs/rq_compare_bp_recall.png", width = 8, height = 3)

