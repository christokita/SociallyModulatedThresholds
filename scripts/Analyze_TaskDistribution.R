################################################################################
#
# Analyze distribution of tasks
#
################################################################################

rm(list = ls())
source("scripts/util/__Util__MASTER.R")
library(RColorBrewer)
library(scales)


####################
# Load data
####################
load("output/Rdata/_ProcessedData/TaskDist/Sigma0.1-Epsilon0-Beta1.1-Delta0.6.Rdata")


####################
# Process data
####################
cumulative_dist <- compiled_data %>% 
  as.data.frame() %>% 
  group_by(n, sim, chunk) %>% 
  mutate(Id = 1:length(Task1)) %>% 
  arrange(Task1, Id, .by_group = TRUE) %>% 
  mutate(Cumu_task1 = Task1 / sum(Task1),
         Cumu_task2 = Task2 / sum(Task2),
         Rank_task1 = 1:length(Task1)) %>%
  mutate(Cumu_task1 = cumsum(Cumu_task1),
         Rank_task1Cum = Rank_task1/length(Rank_task1)) %>% 
  arrange(Task2, Id, .by_group = TRUE) %>% 
  mutate(Rank_task2 = 1:length(Task1),
         Cumu_task2 = cumsum(Cumu_task2),
         Rank_task2Cum = Rank_task2/length(Rank_task2))

# Summarise
cumulative_summary <- cumulative_dist %>% 
  group_by(n, Rank_task1Cum) %>% 
  summarise(mean_cum = mean(Cumu_task1),
            SE_cum = sd(Cumu_task1) / sqrt(length(Cumu_task1)))

####################
# Plot
####################
gg_cumsum <- ggplot(data = cumulative_summary, aes(x = Rank_task1Cum, y = mean_cum)) +
  geom_abline(slope = 1, intercept = 0, size = 0.1, color = "#737373") +
  geom_errorbar(aes(ymax = mean_cum + SE_cum , ymin = mean_cum - SE_cum), width = 0) +
  geom_point(color = "#045a8d", size = 0.5) +
  theme_ctokita() +
  facet_wrap(~n)

gg_cumsum


test <- cumulative_dist %>% filter(n == 100)

gg_cumsum <- ggplot(data = test, aes(x = Rank_task1Cum, y = Cumu_task1, group = Rank_task1Cum)) +
  geom_abline(slope = 1, intercept = 0, size = 0.1, color = "#737373") +
  geom_boxplot() +
  scale_x_continuous(limits = c(0, 1)) +
  theme_ctokita() +
  facet_wrap(~n)

gg_cumsum

####################
# Load task tally data
####################
load("output/Rdata/_ProcessedData/TaskTally/Sigma0-Epsilon0.1-Beta1.1/080.Rdata")

# Analyze frequency of task performance
task_perf <- as.data.frame(do.call('rbind', listed_data)) %>% 
  mutate(Task1Freq = Task1 / n,
         Task2Freq = Task2 / n,
         ID = paste0(sim, "-", chunk))

# Plot over time
task_avg <- task_perf %>% 
  group_by(t) %>% 
  summarise(Task1_mean = mean(Task1Freq),
            Task1_sd = sd(Task1Freq))
task_perf_look <- task_perf %>% 
  filter(t > 50/0.8 & t > (50/0.8+100))
gg_timetally <- ggplot(data = task_perf_look, aes(x = t, y = Task1Freq, group = ID)) +
  geom_line(size = 0.4, alpha = 0.2) +
  geom_vline(xintercept = 50/0.8) +
  theme_ctokita()
gg_timetally

# Figure out range of task freq
quantile(task_perf$Task1Freq, probs = seq(0, 1, 0.1))
