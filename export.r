library("xtable")

project_summary %>% group_by(lang) %>%
  summarize(n(), 
            min(stars),max(stars), 
            min(commits), max(commits), 
            min(releases), max(releases)) %>%
  xtable()
