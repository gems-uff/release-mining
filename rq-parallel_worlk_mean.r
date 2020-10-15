
library(tidyverse)
library("reshape2")

releases <- read.csv("releases.csv")

releases_bproj <- releases %>% group_by(project) %>% 
  summarise(merges_mean = 100*sum(merges)/sum(commits), releases.total=n())

releases_few_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  filter((100*merges/commits) < merges_mean) %>%
  group_by(project) %>%
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            releases=n())

releases_many_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  filter((100*merges/commits) >= merges_mean) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            releases=n())

releases_bproj <- releases_bproj %>% 
  inner_join(releases_few_merges_bproj, by="project") %>%
  inner_join(releases_many_merges_bproj, by="project", suffix=c(".few",".many")) 


# H2_0 Test

wilcox.test(releases_bproj$time_precision.few, releases_bproj$time_precision.many)
cliff.delta(releases_bproj$time_precision.few, releases_bproj$time_precision.many)

wilcox.test(releases_bproj$time_recall.few, releases_bproj$time_recall.many)
cliff.delta(releases_bproj$time_recall.few, releases_bproj$time_recall.many)

wilcox.test(releases_bproj$range_precision.few, releases_bproj$range_precision.many)
#cliff.delta(releases_bproj$range_precision.few, releases_bproj$range_precision.many)

wilcox.test(releases_bproj$range_recall.few, releases_bproj$range_recall.many)


releases_bproj_melted <- releases_bproj %>% 
  select(-merges_mean, -releases.total, -releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time", TRUE ~ "range"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many"))
  
releases_bproj_melted %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    facet_grid(rows = vars(strategy), scales = "free") +
    theme_bw(base_size = 14)

releases_bproj_melted %>%
  filter(grepl("precision", variable), grepl("time", strategy)) %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Quantity of merges effect on time-based precision") +
    geom_boxplot() +
    scale_x_discrete(labels=c("time_precision.few" =  "few",
                              "time_precision.many" = "many")) +
    ylim(0,1) +
    xlab("") + ylab("precision") +
    theme_bw(base_size = 14) + coord_flip() +
    ggsave("../paper/figs/rq_parallel_work_time_precision_bp.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(grepl("precision", variable), grepl("range", strategy)) %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Quantity of merges effect on range-based precision") +
    geom_boxplot() +
    scale_x_discrete(labels=c("range_precision.few" =  "few",
                              "range_precision.many" = "many")) +
    ylim(0,1) +
    xlab("") + ylab("precision") +
    theme_bw(base_size = 14) + coord_flip() +
    ggsave("../paper/figs/rq_parallel_work_range_precision_bp.png", width = 8, height = 2)

releases_bproj_melted %>% 
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  facet_grid(rows = vars(strategy), scales = "free") +
  theme_bw(base_size = 14)

  
releases_bproj_melted %>%
  filter(grepl("recall", variable), grepl("time", strategy)) %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Quantity of merges effect on time-based recall") +
    geom_boxplot() +
    scale_x_discrete(labels=c("time_recall.few" =  "few",
                              "time_recall.many" = "many")) +
    ylim(0,1) +
    xlab("") + ylab("recall") +
    theme_bw(base_size = 14) + coord_flip() +
    ggsave("../paper/figs/rq_parallel_work_time_recall_bp.png", width = 8, height = 2)

releases_bproj_melted %>%
  filter(grepl("recall", variable), grepl("range", strategy)) %>%
  ggplot(aes(x=variable, y=value)) +
    ggtitle("Quantity of merges effect on range-based recall") +
    geom_boxplot() +
    scale_x_discrete(labels=c("range_recall.few" =  "few",
                              "range_recall.many" = "many")) +
    ylim(0,1) +
    xlab("") + ylab("recall") +
    theme_bw(base_size = 14) + coord_flip() +
    ggsave("../paper/figs/rq_parallel_work_range_recall_bp.png", width = 8, height = 2)
  
