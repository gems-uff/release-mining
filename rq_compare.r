#install.packages("tidyverse")
#install.packages("reshape2")
#install.packages("PMCMRplus")
library("tidyverse")
library("effsize")
library("reshape2")
library("PMCMR")
#library("PMCMRplus")


# Summarize Strategies
releases_bproj %>% summarize(time_naive_precision = mean(time_naive_precision),
                             time_precision = mean(time_precision),
                             range_precision = mean(range_precision),
                             time_naive_recall = mean(time_naive_recall),
                             time_recall = mean(time_recall),
                             range_recall = mean(range_recall),
                             time_naive_fmeasure = mean(time_naive_fmeasure),
                             time_fmeasure = mean(time_fmeasure),
                             range_fmeasure = mean(range_fmeasure)) %>%
  gather() %>% as.data.frame() %>% mutate_if(is.numeric, ~round(.*100, 2))


### Precision
shapiro.test(releases_bproj$time_precision)
shapiro.test(releases_bproj$range_precision)
wilcox.test(releases_bproj$range_precision, releases_bproj$time_precision, paired = TRUE)$p.value %>% round(4)

### Recal
shapiro.test(releases_bproj$time_recall)
shapiro.test(releases_bproj$range_recall)
wilcox.test(releases_bproj$range_recall, releases_bproj$time_recall, paired = TRUE)
wilcox.test(releases_bproj$range_recall, releases_bproj$time_recall, paired = TRUE)$p.value %>% round(4)
cliff.delta(releases_bproj$range_recall, releases_bproj$time_recall)

### F-measure
shapiro.test(releases_bproj$time_fmeasure)
shapiro.test(releases_bproj$range_fmeasure)

wilcox.test(releases_bproj$range_fmeasure, releases_bproj$time_fmeasure, paired = TRUE)
cliff.delta(releases_bproj$range_fmeasure, releases_bproj$time_fmeasure)

## Boxplots
releases_bproj %>% summarize(min(time_precision), min(range_precision),
                             mean(time_precision), mean(range_precision),
                             median(time_precision), median(range_precision)) %>%
  gather() %>% as.data.frame() %>% mutate_if(is.numeric, ~round(.*100, 2))

releases_bproj_melted %>%
  filter(grepl("precision", variable), !grepl("naive", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    scale_x_discrete(labels=c("time_precision" = "time-based",
                              "range_precision" =  "range-based")) +
    ylab("") + ylim(0.85,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_best_bp_precision.png", width = 8, height = 2)

releases_bproj %>% summarize(min(time_recall), min(range_recall))
releases_bproj_melted %>%
  filter(grepl("recall", variable), !grepl("naive", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  scale_x_discrete(labels=c("time_recall" = "time-based",
                            "range_recall" =  "range-based")) +
  ylab("") + ylim(0.7,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_best_bp_recall.png", width = 8, height = 2)

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
