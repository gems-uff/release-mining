library(ggplot2)
library("reshape2")

projects <- read.csv("projects.csv")
projects$project <- projects$name
projects %>% names()
releases <- read.csv("releases.csv")

# Number of commits and releases
releases %>% summarize(commits=sum(commits), releases=n())

# Number of releases


project_summary <- releases %>% group_by(project) %>% summarize(lang=first(lang), commits=sum(commits), releases=n())
project_summary %>% names()

project_summary <- project_summary %>% 
  merge(projects %>% select(project,stars), by="project") %>% 
  select(project, lang, commits, releases, stars)

project_summary %>% select(project, lang, stars, releases, commits) %>% melt() %>%
  ggplot(aes(x=lang)) +
  geom_boxplot(aes(y=value)) +
  coord_flip() +
  facet_grid(cols = vars(variable), scales = "free") +
  ylab("") + xlab("") +
  theme_bw(base_size=18) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) + 
  ggsave("../paper/figs/summary.png", width = 8, height = 6)
           