


base_treshold <- 100 * mean(releases$base_releases_qnt / releases$commits)
base_treshold <- mean(releases$base_releases_qnt)


releases_few_bases_bproj <- releases %>% 
  filter(base_releases_qnt < base_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases=n())

releases_many_bases_bproj <- releases %>% 
  filter(base_releases_qnt > base_treshold) %>%
  group_by(project) %>% 
  summarise(time_precision = mean(time_precision),
            time_recall = mean(time_recall),
            time_fmeasure = mean(time_fmeasure),
            range_precision = mean(range_precision),
            range_recall = mean(range_recall),
            range_fmeasure = mean(range_fmeasure),
            releases=n())

releases_bases_bproj <- releases_few_bases_bproj %>% 
  inner_join(releases_many_bases_bproj, by="project", suffix=c(".few",".many")) 

releases_bases_bproj_melted <- releases_bases_bproj %>% 
  select(-releases.few, -releases.many) %>%
  melt() %>%
  mutate(group = case_when(grepl("few", variable) ~ "few", TRUE ~ "many"),
         strategy = case_when(grepl("time", variable) ~ "time",
                              grepl("range", variable) ~ "range",
                              TRUE ~ "fmeasure"))

# H2_0 Test
100 * releases_bases_bproj %>%
  summarise(time_precision.few = mean(time_precision.few),
            time_precision.many = mean(time_precision.many),
            range_precision.few = mean(range_precision.few),
            range_precision.many = mean(range_precision.many)) %>% round(4)

shapiro.test(releases_bases_bproj$time_precision.few)
shapiro.test(releases_bases_bproj$time_precision.many)
wilcox.test(releases_bases_bproj$time_precision.few, 
            releases_bases_bproj$time_precision.many, paired = TRUE)
cliff.delta(releases_bases_bproj$time_precision.few, 
            releases_bases_bproj$time_precision.many)


shapiro.test(releases_bases_bproj$range_precision.few)
shapiro.test(releases_bases_bproj$range_precision.many)
wilcox.test(releases_bases_bproj$range_precision.few, 
            releases_bases_bproj$range_precision.many, paired = TRUE)


100 * releases_bases_bproj %>%
  summarise(time_recall.few = mean(time_recall.few),
            time_recall.many = mean(time_recall.many),
            range_recall.few = mean(range_recall.few),
            range_recall.many = mean(range_recall.many)) %>% round(4)

shapiro.test(releases_bases_bproj$time_recall.few)
shapiro.test(releases_bases_bproj$time_recall.many)
wilcox.test(releases_bases_bproj$time_recall.few, 
            releases_bases_bproj$time_recall.many, paired = TRUE)
cliff.delta(releases_bases_bproj$time_recall.few, 
            releases_bases_bproj$time_recall.many)

releases_bases_bproj %>% summarize(min(time_recall.few), min(time_recall.many),
                                   min(range_recall.few), min(range_recall.many))
releases_bases_bproj_melted %>%
  filter(grepl("recall", variable), grepl("^time", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  scale_x_discrete(labels=c("time_recall.many" = "many",
                            "time_recall.few" =  "few")) +
#  facet_grid(rows = vars(strategy), scales = "free") +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_factors_base_bp_recall.png", width = 8, height = 2)

# F-measure

100 * releases_bases_bproj %>%
  summarise(time_fmeasure.few = mean(time_fmeasure.few),
            time_fmeasure.many = mean(time_fmeasure.many),
            range_fmeasurel.few = mean(range_fmeasure.few),
            range_fmeasure.many = mean(range_fmeasure.many)) %>% round(4)


