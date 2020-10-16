#install.packages("tidyverse")
#install.packages("reshape2")
library("tidyverse")
library("effsize")
library("reshape2")

releases <- read.csv("releases.csv")

releases_bproj <- releases %>% 
  group_by(project) %>%
  summarize(time_precision=mean(time_precision),
            time_naive_precision=mean(time_naive_precision),
            range_precision=mean(range_precision),
            time_recall=mean(time_recall),
            time_naive_recall=mean(time_naive_recall),
            range_recall=mean(range_recall))

releases_overall <- releases_bproj %>%
  summarize(time_precision=mean(time_precision),
            time_naive_precision=mean(time_naive_precision),
            range_precision=mean(range_precision),
            time_recall=mean(time_recall),
            time_naive_recall=mean(time_naive_recall),
            range_recall=mean(range_recall))

releases_overall * 100 

#
# Compare precision
#
shapiro.test(releases_bproj$time_precision)
shapiro.test(releases_bproj$range_precision)
wilcox.test(releases_bproj$time_precision, releases_bproj$range_precision, paired = TRUE)
cliff.delta(releases_bproj$time_precision, releases_bproj$range_precision)

## Boxplot - Precision
releases_bproj_melted <- releases_bproj %>% melt() %>% 
  mutate(variable = factor(variable, levels = c("time_naive_precision",
                                                "time_naive_recall",
                                                "time_precision",
                                                "time_recall",
                                                "range_precision",
                                                "range_recall")))
releases_bproj_melted %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    scale_x_discrete(labels=c("range_precision" =  "range-based",
                              "time_naive_precision" = "naive time-based",
                              "time_precision" = "time-based")) +
    ylab("") + ylim(0,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    #theme(axis.text.y = element_text(angle = 30, hjust = 1)) +
    ggsave("../paper/figs/rq_compare_bp_precision.png", width = 8, height = 3)

## Scatter - Strategy per project
releases_bproj %>%
  ggplot(aes(x=time_precision, y=range_precision)) +
  geom_point() +
  geom_abline() +
  xlim(0,1) + xlab("time-based") +
  ylim(0,1) + ylab("range-based") +
  theme_bw(base_size = 18)

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

