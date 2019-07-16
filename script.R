library(tidyverse)
library(vegan)
library(betapart)

### import data ###

# sites
sites <- rio::import("../site data.xlsx")

# surveys
data_BB <- rio::import("../Bumblebees_GINFRA_allfix.xlsx") %>%
  select(-contains("sex"), - contains("pollen"), -Observer, -Honeybee, -Notes, - Others) %>% as.tbl %>%
  replace(., is.na(.), 0) %>% 
  dplyr::select(1,2,10:29) %>%
  group_by(Landscape, Transect_type) %>% summarise_all(sum)



data <- data_BB %>% left_join(sites) 

### test effect of habitat types ###

### NMDS ###
data.perm <- data %>% ungroup %>% filter(rowSums(.[,-c(1:2, 23:29)]) > 0)

nmds <- metaMDS(data.perm[,-c(1:2, 23:29)], trymax = 10000, maxit = 20000)

# plot #
# prepare scores
nmds.scores <- as.data.frame(scores(nmds))
nmds.scores$site <- rownames(nmds.scores)
nmds.scores$road <- data.perm$`Road Density`
nmds.scores$power <- data.perm$Powerline
nmds.scores$habitat <- data.perm$Transect_type

species.scores <- as.data.frame(scores(nmds, "species"))
species.scores$species <- rownames(species.scores)

# create hull polygons
# roads
road.low <- nmds.scores[nmds.scores$road == "low", ][chull(nmds.scores[nmds.scores$road == "low", c("NMDS1", "NMDS2")]), ] 
road.high <- nmds.scores[nmds.scores$road == "high", ][chull(nmds.scores[nmds.scores$road == "high", c("NMDS1", "NMDS2")]), ]
hull.road <- rbind(road.low, road.high) 

# powerlines
power.yes <- nmds.scores[nmds.scores$power == "Yes", ][chull(nmds.scores[nmds.scores$power == "Yes", c("NMDS1", "NMDS2")]), ] 
power.no <- nmds.scores[nmds.scores$power == "No", ][chull(nmds.scores[nmds.scores$power == "No", c("NMDS1", "NMDS2")]), ]
hull.power <- rbind(power.yes, power.no) 

# habitat
habitat.1 <- nmds.scores[nmds.scores$habitat == 
                           "Between fields", ][chull(nmds.scores[nmds.scores$habitat == 
                                                                   "Between fields", c("NMDS1", "NMDS2")]), ] 
habitat.2 <- nmds.scores[nmds.scores$habitat == 
                           "Big road", ][chull(nmds.scores[nmds.scores$habitat == 
                                                             "Big road", c("NMDS1", "NMDS2")]), ]
habitat.3 <- nmds.scores[nmds.scores$habitat == 
                           "Pasture", ][chull(nmds.scores[nmds.scores$habitat == 
                                                            "Pasture", c("NMDS1", "NMDS2")]), ] 
habitat.4 <- nmds.scores[nmds.scores$habitat == 
                           "Powerline", ][chull(nmds.scores[nmds.scores$habitat == 
                                                              "Powerline", c("NMDS1", "NMDS2")]), ] 
habitat.5 <- nmds.scores[nmds.scores$habitat == 
                           "Small road", ][chull(nmds.scores[nmds.scores$habitat == 
                                                               "Small road", c("NMDS1", "NMDS2")]), ] 
hull.habitat <- rbind(habitat.1, habitat.2) 
hull.habitat <- rbind(hull.habitat, habitat.3) 
hull.habitat <- rbind(hull.habitat, habitat.4) 
hull.habitat <- rbind(hull.habitat, habitat.5) 

# plots
ggplot() + 
  geom_polygon(data=hull.habitat,aes(x=NMDS1,y=NMDS2,fill=habitat ,group=habitat ),alpha=0.30) + # add the convex hulls
  geom_point(data=nmds.scores,aes(x=NMDS1,y=NMDS2,shape=habitat,colour=habitat),size=4) + # add the point markers
  geom_text(data=species.scores,aes(x=NMDS1,y=NMDS2,label=species),alpha=0.5) +  # add the species labels
  coord_equal() +
  theme_bw()

ggsave("nmds_plot.svg")

### beta-diversity ###

data %>% group_by(Powerline, `Road Density`) %>% 
  do(data.frame(beta.multi(.[,-c(1:2, 23:29)] %>% mutate_all(function(x){ifelse(x == 0, 0, 1)})))) %>%
  select(-beta.SOR) %>% gather(-1, -2, key = "beta", value = "value") %>%
  ggplot(aes(y = value, x = Powerline)) + 
  geom_bar(stat = "identity", aes(fill = beta)) + 
  facet_grid(. ~ `Road Density`)


beta.labs <- c("Turnover (beta.SIM)", "Nestedness (beta.SNE)", "Total (beta.SOR)")
names(beta.labs) <- c("beta.SIM", "beta.SNE", "beta.SOR")


data %>% group_by(Transect_type) %>% 
  do(data.frame(beta.multi(.[,-c(1:2, 23:29)] %>% mutate_all(function(x){ifelse(x == 0, 0, 1)})))) %>%
  ungroup %>%
  mutate(Transect_type = fct_reorder(Transect_type, beta.SOR)) %>% 
  gather(-1, key = "beta", value = "value") %>% 
  mutate(beta = factor(beta, levels = c("beta.SOR", "beta.SIM", "beta.SNE"))) %>%
  ggplot(aes(y = value, x = Transect_type, color = Transect_type)) + 
  geom_point(size = 4) + 
  facet_wrap(~beta, scales = "free", 
             labeller = labeller(beta = beta.labs)) +
  scale_x_discrete("") + 
  scale_y_continuous("Beta-diversity") + 
  scale_color_discrete("Habitat type") +
  theme_classic() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave("beta.div_plot.svg", width = 8, height = 4.5)
