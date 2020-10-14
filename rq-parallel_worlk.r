
library(tidyverse)


releases <- read.csv("releases.csv")

releases_bproj <- releases_bproj <- releases %>% group_by(project) %>% 
  summarise(merges_mean = mean(merges), releases.total=n())

releases_few_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  group_by(project) %>% 
  filter(merges < merges_mean) %>%
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            releases=n())

releases_many_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  group_by(project) %>% 
  filter(merges >= merges_mean) %>%
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
cliff.delta(releases_bproj$range_precision.few, releases_bproj$range_precision.many)

wilcox.test(releases_bproj$range_recall.few, releases_bproj$range_recall.many)


releases_bproj %>% 
  select(-merges_mean, -releases.total, -releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time", TRUE ~ "range"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    facet_grid(rows = vars(strategy), scales = "free") +
    theme_bw(base_size = 18) + 
    ggsave("../paper/figs/rq_parallel_work_precision_bp.png", width = 8, height = 6)


releases_bproj %>% 
  select(-merges_mean, -releases.total, -releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time", TRUE ~ "range"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  facet_grid(rows = vars(strategy), scales = "free") +
  theme_bw(base_size = 18) + 
  ggsave("../paper/figs/rq_parallel_work_recall_bp.png", width = 8, height = 6)



### Normalized

releases_bproj <- releases_bproj <- releases %>% group_by(project) %>% 
  summarise(merges_mean = mean(merges)/mean(commits), releases.total=n())

releases_few_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  group_by(project) %>% 
  filter((merges/commits) < merges_mean) %>%
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            releases=n())

releases_many_merges_bproj <- releases %>% 
  inner_join(releases_bproj, by="project") %>%
  group_by(project) %>% 
  filter((merges/commits) >= merges_mean) %>%
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
cliff.delta(releases_bproj$range_precision.few, releases_bproj$range_precision.many)

wilcox.test(releases_bproj$range_recall.few, releases_bproj$range_recall.many)


releases_bproj %>% 
  select(-merges_mean, -releases.total, -releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time", TRUE ~ "range"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  facet_grid(rows = vars(strategy), scales = "free") +
  theme_bw(base_size = 18) 
  

releases_bproj %>% 
  select(-merges_mean, -releases.total, -releases.few, -releases.many) %>%
  melt() %>%
  mutate(strategy = case_when(grepl("time", variable) ~ "time", TRUE ~ "range"),
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  filter(grepl("recall", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  facet_grid(rows = vars(strategy), scales = "free") +
  theme_bw(base_size = 18) 
  

