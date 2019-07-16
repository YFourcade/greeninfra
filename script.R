library(tidyverse)
library(vegan)
library(betapart)

### import data ###

# sites
sites <- rio::import("../site data.xlsx")
sites$Landscape <- as.numeric(gsub(4711, 7411, sites$Landscape)) # fix ?

# surveys
data_BB <- rio::import("../Bumblebees_GINFRA_allfix.xlsx") %>%
  select(-contains("sex"), - contains("pollen"), -Observer, -Honeybee, -Notes, - Others) %>% as.tbl %>%
  replace(., is.na(.), 0) %>% 
  dplyr::select(1,2,10:29) %>%
  group_by(Landscape, Transect_type) %>% summarise_all(sum) %>%
  gather(-1, -2, key = "Species", value = "n")

data_But <- rio::import("../Butterflies_GINFRA_allfix.xlsx") %>%
  select(-Observer, -Note) %>% as.tbl %>%
  replace(., is.na(.), 0) %>% 
  dplyr::select(1,2,10:73) %>%
  group_by(Landscape, Transect_type) %>% summarise_all(sum) %>%
  gather(-1, -2, key = "Species", value = "n")

data_Plants <- rio::import("../PlantsPlots_GINFRA.xlsx") %>%
  select(-Observer) %>% as.tbl %>% mutate(value = 1) %>%
  spread(key = "Species", value = "value", fill = 0) %>% 
  dplyr::select(1,2,5:138) %>%
  rename(Transect_type = `Transect Type`) %>%
  group_by(Landscape, Transect_type) %>% summarise_all(sum) %>%
  gather(-1, -2, key = "Species", value = "n")

data_Plants$Landscape <- as.numeric(gsub(5560, 5561, data_Plants$Landscape)) # fix ?
data_Plants$Transect_type <- gsub("Between fields (between meadows)", "Between fields", data_Plants$Transect_type, fixed=TRUE)
data_Plants$Transect_type <- gsub("Small road (eastern transect)", "Small road", data_Plants$Transect_type, fixed=TRUE)

data <- bind_rows("Bumblebees" = data_BB, "Butterflies" = data_But, "Plants" = data_Plants, .id = "taxon") %>% left_join(sites) 

### test effect of habitat types ###

### NMDS ###
ndms.plots <- c()
for(i in unique(data$taxon)){
    data.nmds <- data %>% filter(taxon == i) %>% ungroup %>% 
      dplyr::select(2:8) %>%
      spread(key = Species, value = n) %>%
      filter(rowSums(.[,-c(1:5)]) > 0)
    
    nmds <- metaMDS(data.nmds[,-c(1:5)], trymax = 10000, maxit = 20000)
    
    # plot #
    # prepare scores
    nmds.scores <- as.data.frame(scores(nmds))
    nmds.scores$site <- rownames(nmds.scores)
    nmds.scores$road <- data.nmds$`Road Density`
    nmds.scores$power <- data.nmds$Powerline
    nmds.scores$habitat <- factor(data.nmds$Transect_type, levels = c("Powerline",
                                                                      "Between fields",
                                                                      "Pasture",
                                                                      "Small road",
                                                                      "Big road"))
    
    
    # species.scores <- as.data.frame(scores(nmds, "species"))
    # species.scores$species <- rownames(species.scores)
    
    # create hull polygons
    
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
    
    hull.habitat$habitat <- factor(hull.habitat$habitat, levels = c("Powerline",
                                                                    "Between fields",
                                                                    "Pasture",
                                                                    "Small road",
                                                                    "Big road"))
    
    
    ndms.plots <- rbind.data.frame(ndms.plots, 
                                   cbind.data.frame(taxon = i,
                                   rbind.data.frame(cbind.data.frame(what = "hull", hull.habitat),
                                                    cbind.data.frame(what = "scores", nmds.scores)
                                                    )
                                   )
    )
}

ggplot() + 
  geom_polygon(data=ndms.plots[ndms.plots$what == "hull",],
               aes(x=NMDS1,y=NMDS2,fill=habitat ,group=habitat ),alpha=0.25) + # add the convex hulls
  # geom_text(data=species.scores,aes(x=NMDS1,y=NMDS2,label=species),alpha=0.5, size = 3.5) +  # add the species labels
  geom_point(data=ndms.plots[ndms.plots$what == "scores",],
             aes(x=NMDS1,y=NMDS2,shape=habitat,colour=habitat),size=1) + # add the point markers
  facet_grid(~ taxon) +
  coord_equal() +
  scale_color_discrete("Habitat type") +
  scale_fill_discrete("Habitat type") +
  scale_shape_discrete("Habitat type") +
  theme_bw()

ggsave("nmds_plot.svg", width = 12, height = 10)

### beta-diversity ###

data %>% group_by(Powerline, `Road Density`) %>% 
  do(data.frame(beta.multi(. %>% dplyr::select(4,5) %>% spread(key = Species, value = n) %>% 
                             mutate_all(function(x){ifelse(x == 0, 0, 1)})))) %>%
  select(-beta.SOR) %>% gather(-1, -2, key = "beta", value = "value") %>%
  ggplot(aes(y = value, x = Powerline)) + 
  geom_bar(stat = "identity", aes(fill = beta)) + 
  facet_grid(. ~ `Road Density`)


beta.labs <- c("Turnover (beta.SIM)", "Nestedness (beta.SNE)", "Total (beta.SOR)")
names(beta.labs) <- c("beta.SIM", "beta.SNE", "beta.SOR")

extract_beta <- function(x){
  y <- x %>% ungroup %>% spread(key = Species, value = n) %>% 
    mutate_all(function(x){ifelse(x == 0, 0, 1)})
  b <- beta.multi(y[,-c(1:10)])
  return(as.data.frame(b))
}

data %>% group_by(taxon, Transect_type) %>% 
  do(extract_beta(.)) %>%
  ungroup %>%
  mutate(Transect_type = fct_reorder(Transect_type, beta.SOR)) %>% 
  gather(-1, -2, key = "beta", value = "value") %>% 
  mutate(beta = factor(beta, levels = c("beta.SOR", "beta.SIM", "beta.SNE"))) %>%
  ggplot(aes(y = value, x = Transect_type, color = Transect_type)) + 
  geom_point(size = 4) + 
  facet_grid(beta~taxon, scales = "free", 
             labeller = labeller(beta = beta.labs)) +
  scale_x_discrete("") + 
  scale_y_continuous("Beta-diversity") + 
  scale_color_discrete("Habitat type") +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave("beta.div_plot.svg", width = 9, height = 7)



#######################
## clean environment ##
#######################
gdata::keep(data, 
            ndms.plots,
            sure = T)



