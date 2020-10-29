releases_bproj %>% select(project, time_naive_recall, time_recall) %>% write.xlsx("bproj.xlsx")

# Test normal distribution
shapiro.test(releases_bproj$time_naive_precision)
shapiro.test(releases_bproj$time_precision)

shapiro.test(releases_bproj$time_naive_recall)
shapiro.test(releases_bproj$time_recall)

# Compare the precision of the strategies
wilcox.test(releases_bproj$time_naive_precision, releases_bproj$time_precision,
            paired = TRUE)
cliff.delta(releases_bproj$time_naive_precision, releases_bproj$time_precision)

# Compare the recall of the strategies
wilcox.test(releases_bproj$time_naive_recall, releases_bproj$time_recall,
            paired = TRUE)
cliff.delta(releases_bproj$time_naive_recall, releases_bproj$time_recall)

# Summarize Strategies
releases_bproj %>% summarize(time_naive_precision = mean(time_naive_precision),
                             time_precision = mean(time_precision),
                             time_naive_recall = mean(time_naive_recall),
                             time_recall = mean(time_recall),
                             time_fmeasure = mean(time_fmeasure),
                             time_naive_fmeasure = mean(time_naive_fmeasure))
                             
releases_bproj_melted %>% 
  filter(grepl("precision", variable), grepl("time", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  scale_x_discrete(labels=c("time_precision" = "reachable",
                            "time_naive_precision" =  "all")) +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_naive_bp_precision.png", width = 8, height = 2)


releases_bproj_melted %>% 
  filter(grepl("recall", variable), grepl("time", variable)) %>%
  ggplot(aes(x=variable, y=value)) +
  geom_boxplot() +
  coord_flip() +
  scale_x_discrete(labels=c("time_recall" = "reachable",
                            "time_naive_recall" =  "all")) +
  ylab("") + ylim(0,1) +
  xlab("") + coord_flip() + 
  theme_bw(base_size = 14) +
  ggsave("../paper/figs/rq_naive_bp_recall.png", width = 8, height = 2)


releases_bproj %>% filter(time_naive_recall != time_recall) %>% 
  select(time_recall, time_naive_recall)

releases %>% filter(time_naive_recall != time_recall) %>% 
  select(project, name, time_recall, time_naive_recall)
