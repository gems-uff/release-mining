library(tidyverse)

# Parallel Work


releases$pwork <- 100 * releases$committers / releases$commits
pwork_treshold <- mean(releases$pwork)
# pwork_treshold <- 100 * sum(releases$committers) / sum(releases$commits)

releases_few_committers_bproj <- releases %>% 
  filter(pwork < pwork_treshold) %>%
  group_by(project) %>%
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases=n())

releases_many_committers_bproj <- releases %>% 
  filter(pwork >= pwork_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases=n())

releases_committers_bproj <- releases_few_committers_bproj %>% 
  #inner_join(releases_few_committers_bproj, by="project") %>%
  inner_join(releases_many_committers_bproj, by="project", suffix=c(".few",".many")) 

releases_committers_bproj_melted <- releases_committers_bproj %>% 
  select(-releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time",
                              grepl("range", variable) ~ "range",
                              TRUE ~ "fmeasure"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many"))



###
# Precision
100 * releases_committers_bproj %>%
  summarise(time_precision.few = mean(time_precision.few),
            time_precision.many = mean(time_precision.many),
            range_precision.few = mean(range_precision.few),
            range_precision.many = mean(range_precision.many))

shapiro.test(releases_committers_bproj$time_precision.few)
shapiro.test(releases_committers_bproj$time_precision.many)
wilcox.test(releases_committers_bproj$time_precision.few, 
            releases_committers_bproj$time_precision.many, paired = TRUE)
cliff.delta(releases_committers_bproj$time_precision.few, 
            releases_committers_bproj$time_precision.many)

shapiro.test(releases_committers_bproj$range_precision.few)
shapiro.test(releases_committers_bproj$range_precision.many)
wilcox.test(releases_committers_bproj$range_precision.few, 
            releases_committers_bproj$range_precision.many, paired = TRUE)
cliff.delta(releases_committers_bproj$range_precision.few, 
            releases_committers_bproj$range_precision.many)


100 * releases_committers_bproj %>%
  summarise(time_recall.few = mean(time_recall.few),
            time_recall.many = mean(time_recall.many),
            range_recall.few = mean(range_recall.few),
            range_recall.many = mean(range_recall.many))

shapiro.test(releases_committers_bproj$time_recall.few)
shapiro.test(releases_committers_bproj$time_recall.many)
wilcox.test(releases_committers_bproj$time_recall.few,
            releases_committers_bproj$time_recall.many, paired = TRUE)
cliff.delta(releases_committers_bproj$time_recall.few,
            releases_committers_bproj$time_recall.many)

#shapiro.test(releases_committers_bproj$range_recall.few)
#shapiro.test(releases_committers_bproj$range_recall.many)
#wilcox.test(releases_committers_bproj$range_recall.few,
#              releases_committers_bproj$range_recall.many, paired = TRUE)





wilcox.test(releases_committers_bproj$range_recall.many, 
            releases_committers_bproj$time_recall.many, paired = TRUE)
cliff.delta(releases_committers_bproj$range_recall.many, 
            releases_committers_bproj$time_recall.many)

wilcox.test(releases_committers_bproj$range_fmeasure.many, 
            releases_committers_bproj$time_fmeasure.many, paired = TRUE)

cliff.delta(releases_committers_bproj$range_fmeasure.many, 
            releases_committers_bproj$time_fmeasure.many)


cliff.delta(releases_bproj$range_fmeasure, 
            releases_bproj$time_fmeasure)


releases_committers_bproj_melted %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c("time_precision.many" = "many",
                              "time_precision.few" =  "few",
                              "range_precision.many" = "many",
                              "range_precision.few" =  "few")) +
    facet_grid(rows = vars(strategy), scales = "free") +
    ylab("") + ylim(0,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_pwork_col_bp_precision.png", width = 8, height = 4)


releases_committers_bproj_melted %>%
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c("time_recall.many" = "many",
                              "time_recall.few" =  "few",
                              "range_recall.many" = "many",
                              "range_recall.few" =  "few")) +
    facet_grid(rows = vars(strategy), scales = "free") +
    ylab("") + ylim(0,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_pwork_col_bp_recall.png", width = 8, height = 4)



releases_committers_bproj_melted %>%
  filter(grepl("fmeasure", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c("time_fmeasure.many" = "many",
                              "time_fmeasure.few" =  "few",
                              "range_fmeasure.many" = "many",
                              "range_fmeasure.few" =  "few")) +
    facet_grid(rows = vars(strategy), scales = "free") +
    ylab("") + ylim(0,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_pwork_col_bp_fmeasure.png", width = 8, height = 4)

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
  
