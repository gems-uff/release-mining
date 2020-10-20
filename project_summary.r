library(tidyverse)
library("reshape2")
library("effsize")
Sys.setenv(LANG = "en")

projects <- read.csv("projects.csv")
projects$project <- projects$name
projects %>% names()
releases <- read.csv("releases.csv")

# Number of commits and releases
releases %>% summarize(commits=sum(commits), releases=n())

project_summary <- releases %>% 
  group_by(project) %>% 
  summarize(lang=first(lang), commits=sum(commits), releases=n()) %>%
  merge(projects %>% select(project,stars), by="project")

project_summary %>% select(project, lang, stars, releases, commits) %>% melt() %>%
  ggplot(aes(x=lang)) +
  geom_boxplot(aes(y=value)) +
  coord_flip() +
  facet_grid(cols = vars(variable), scales = "free") +
  ylab("") + xlab("") +
  theme_bw(base_size=18) +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) + 
  ggsave("../paper/figs/summary.png", width = 8, height = 6)

projects %>% count()
releases %>% count()           
releases %>% select(commits) %>% sum()
103 / releases %>% count()

releases_bproj <- releases %>% 
  group_by(project) %>%
  summarize(#time_naive_precision=mean(time_naive_precision),
            time_precision=mean(time_precision),
            range_precision=mean(range_precision),
            # time_naive_recall=mean(time_naive_recall),
            time_recall=mean(time_recall),
            range_recall=mean(range_recall),
            # time_naive_fmeasure=mean(time_naive_fmeasure),
            time_fmeasure=mean(time_fmeasure),
            range_fmeasure=mean(range_fmeasure))

releases_overall <- releases_bproj %>%
  summarize(#time_naive_precision=mean(time_naive_precision),
            time_precision=mean(time_precision),
            range_precision=mean(range_precision),
            #time_naive_recall=mean(time_naive_recall),
            time_recall=mean(time_recall),
            range_recall=mean(range_recall),
            #time_naive_fmeasure=mean(time_naive_fmeasure),
            time_fmeasure=mean(time_fmeasure),
            range_fmeasure=mean(range_fmeasure))

releases_overall * 100 

releases_bproj_melted <- releases_bproj %>% melt() %>% 
  mutate(variable = factor(variable, levels = c("time_naive_precision",
                                                "time_naive_recall",
                                                "time_naive_fmeasure",
                                                "time_precision",
                                                "time_recall",
                                                "time_fmeasure",
                                                "range_precision",
                                                "range_recall",
                                                "range_fmeasure")))


#releases %>% view()

