releases <- read.csv("releases.csv")

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
    

release_precision %>%
  filter(type == TRUE) %>% count()


release_precision %>% filter(time > range)

releases_precision %>%
  filter(range < 0.9)
  
  

