install.packages("reshape2")
library("effsize")
library("reshape2")

releases <- read.csv("releases.csv")

# Understand releases
releases %>% ggplot(aes(x=commits)) +
  geom_histogram(binwidth = 1) +
  xlim(1,400) +
  theme_bw(base_size = 18)
  

releases %>% filter(commits == 0) %>% count()


# Precision
releases_precision_bproj <- releases %>%
  group_by(project) %>% 
  summarize(time=mean(time_precision), range=mean(range_precision))
  
releases_precision_bproj %>%
  ggplot(aes(x=time, y=range)) +
  geom_point(alpha=0.5, stroke = 0, size=4, shape=16, show.legend = FALSE) +
  geom_abline(color="red") +
  xlim(0,1) +
  xlab("time precision") +
  ylim(0,1) +
  ylab("range precision") +
  theme_bw(base_size = 18) + ggsave("../paper/figs/release_precision_project_time_vs_range.png", width = 4, height = 4)


release_precision <- releases %>%
  select(project, release=name, commits, time=time_precision, range=range_precision)

release_precision$type <- factor(with(release_precision, time > range))

release_precision

boolColors <- as.character(c("TRUE"="#000000", "FALSE"="#ff0000"))
boolScale <- scale_colour_manual(name="myboolean", values=boolColors)

release_precision %>%
  ggplot(aes(x=time, y=range)) +
    geom_point(aes(color=type),
               alpha=0.5, stroke = 0, size=4, shape=16, show.legend = FALSE) +
    geom_abline(color="red") +
    xlim(0,1) +
    xlab("time precision") +
    ylim(0,1) +
    ylab("range precision") +
    boolScale +
    theme_bw(base_size = 18) + ggsave("../paper/figs/release_precision_time_vs_range.png", width = 4, height = 4)
    

releases_precision_bproj %>% melt(value.name="precision", variable.name="strategy") %>%
  ggplot(aes(x=strategy, y=precision)) +
    geom_boxplot() +
    ylab("Precision") +
    xlab("") +
    coord_flip() +
    theme_bw(base_size = 18) + ggsave("../paper/figs/releases_precision_bproj_boxplot.png", width = 8, height = 3)


release_precision %>%
  filter(type == TRUE) %>% count()


release_precision %>% filter(time > range)

releases_precision %>%
  filter(range < 0.9)

releases_precision_bproj
releases_precision_bproj %>% summarize(time=mean(time), range=mean(range)) %>%
  mutate_if(is.numeric, format, 1)
  
shapiro.test(releases_precision_bproj$time)

shapiro.test(releases_precision_bproj$range)

wilcox.test(releases_precision_bproj$range, releases_precision_bproj$time)


cliff.delta(releases_precision_bproj$range, releases_precision_bproj$time)


# Recall
releases_recall_bproj <- releases %>%
  group_by(project) %>% 
  summarize(time=mean(time_recall), range=mean(range_recall))

releases_recall_bproj %>%
  ggplot(aes(x=time, y=range)) +
  geom_point(alpha=0.5, stroke = 0, size=4, shape=16, show.legend = FALSE) +
  geom_abline(color="red") +
  xlim(0,1) +
  xlab("time recall") +
  ylim(0,1) +
  ylab("range recall") +
  theme_bw(base_size = 18) + ggsave("../paper/figs/release_recall_project_time_vs_range.png", width = 4, height = 4)


release_recall <- releases %>%
  select(project, release=name, commits, time=time_recall, range=range_recall)

releases_recall_bproj %>% summarize(time=mean(time), range=mean(range)) %>%
  mutate_if(is.numeric, format, 1)


release_recall$type <- factor(with(release_recall, time > range))

release_recall

boolColors <- as.character(c("TRUE"="#000000", "FALSE"="#ff0000"))
boolScale <- scale_colour_manual(name="myboolean", values=boolColors)

release_recall %>%
  ggplot(aes(x=time, y=range)) +
  geom_point(aes(color=type),
             alpha=0.5, stroke = 0, size=4, shape=16, show.legend = FALSE) +
  geom_abline(color="red") +
  xlim(0,1) +
  xlab("time recall") +
  ylim(0,1) +
  ylab("range recall") +
  boolScale +
  theme_bw(base_size = 18) + ggsave("../paper/figs/release_recall_time_vs_range.png", width = 4, height = 4)


releases_recall_bproj %>% melt(value.name="precision", variable.name="strategy") %>%
  ggplot(aes(x=strategy, y=precision)) +
  geom_boxplot() +
  ylab("Recall") +
  xlab("") +
  coord_flip() +
  theme_bw(base_size = 18) + ggsave("../paper/figs/releases_recall_bproj_boxplot.png", width = 8, height = 3)


release_recall %>%
  filter(type == TRUE) %>% count()


release_recall %>% filter(time > range)

release_recall %>%
  filter(range < 0.9)

shapiro.test(releases_recall_bproj$time)

shapiro.test(releases_recall_bproj$range)

wilcox.test(releases_recall_bproj$range, releases_recall_bproj$time)

cliff.delta(releases_recall_bproj$range, releases_recall_bproj$time)

