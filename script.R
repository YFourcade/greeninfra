library(tidyverse)
library(vegan)

### import data ###
data_BB <- rio::import("../Bumblebees_GINFRA_allfix.xlsx") %>%
  select(-contains("sex"), - contains("pollen"), -Observer, -Honeybee, -Notes, - Others) %>% as.tbl

### test effect of powerline and road density ###
