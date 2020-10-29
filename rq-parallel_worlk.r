library(tidyverse)

# Parallel Work

cor(releases %>% select(commits, committers, base_releases_qnt), method = "spearman")
cor.test(releases$commits, releases$committers, method = "spearman")
cor.test(releases$commits, releases$base_releases_qnt, method = "spearman")

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
         group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many")) %>%
  mutate(strategy = factor(strategy, levels = c("time",
                                                "range")),
         group = factor(group, levels=c("many", "few")),
         variable = factor(variable, levels=c("time_precision.many",
                                              "time_precision.few",
                                              "time_recall.many",
                                              "time_recall.few",
                                              "range_precision.many",
                                              "range_precision.few",
                                              "range_recall.many",
                                              "range_recall.few")))
          



###
# Precision
100 * releases_committers_bproj %>%
  summarise(time_precision.few = mean(time_precision.few),
            time_precision.many = mean(time_precision.many),
            range_precision.few = mean(range_precision.few),
            range_precision.many = mean(range_precision.many)) %>% round(4)

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
            range_recall.many = mean(range_recall.many)) %>% round(4)

100 * releases_committers_bproj %>%
  summarise(time_fmeasure.few = mean(time_fmeasure.few),
            time_fmeasure.many = mean(time_fmeasure.many),
            range_fmeasure.few = mean(range_fmeasure.few),
            range_fmeasure.many = mean(range_fmeasure.many)) %>% round(4)

shapiro.test(releases_committers_bproj$time_recall.few)
shapiro.test(releases_committers_bproj$time_recall.many)
wilcox.test(releases_committers_bproj$time_recall.few,
            releases_committers_bproj$time_recall.many, paired = TRUE)
cliff.delta(releases_committers_bproj$time_recall.few,
            releases_committers_bproj$time_recall.many)


releases_committers_bproj %>% summarize(min(time_precision.few), min(time_precision.many),
                                        min(range_precision.few), min(range_precision.many))
releases_committers_bproj_melted %>%
  filter(grepl("precision", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c("time_precision.many" = "many",
                              "time_precision.few" =  "few",
                              "range_precision.many" = "many",
                              "range_precision.few" =  "few")) +
    facet_grid(rows = vars(strategy), scales = "free",
               labeller = as_labeller(c("time" = "time-based", "range" = "range-based"))) +
    ylab("") + ylim(0.75,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_factors_bp_collaborators_precision.png", width = 8, height = 3)


releases_committers_bproj %>% summarize(min(time_recall.few), min(time_recall.many),
                                        min(range_recall.few), min(range_recall.many))
releases_committers_bproj_melted %>%
  filter(grepl("recall", variable), grepl("^time", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
    geom_boxplot() +
    coord_flip() +
    scale_x_discrete(labels=c("time_recall.many" = "many",
                              "time_recall.few" =  "few",
                              "range_recall.many" = "many",
                              "range_recall.few" =  "few")) +
    #facet_grid(rows = vars(strategy), scales = "free") +
    ylab("") + ylim(0.45,1) +
    xlab("") + coord_flip() + 
    theme_bw(base_size = 14) +
    ggsave("../paper/figs/rq_factors_bp_collaborators_recall.png", width = 8, height = 2)

