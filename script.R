library(tidyverse)
library(vegan)
library(betapart)
library(emmeans)
library(MuMIn)
library(vegan)

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

## Diversity ##
# species richness
data %>% group_by(Transect_type, taxon, Landscape) %>% 
  summarise(n = length(unique(Species[n > 0]))) %>%
  group_by(taxon) %>% summarise(mean_SR = mean(n))

anov.sr <- lme4::lmer(n ~ taxon + (1|Transect_type), 
                       data = data %>% group_by(Transect_type, taxon, Landscape) %>% 
                        summarise(n = length(unique(Species[n > 0]))))
car::Anova(anov.sr, test.statistic = "F")

pairs(emmeans(anov.sr, ~ taxon))


# Shanon index
extract_shannon <- function(x){
  y <- x %>% ungroup %>% spread(key = Species, value = n)
  shannon <- diversity(y[,-c(1:10)])
  return(cbind.data.frame(y[,2:3],shannon = shannon))
}

dat.shannon <- data %>% group_by(taxon) %>% do(extract_shannon(.))

dat.shannon %>% 
  group_by(taxon) %>% summarise(mean_S = mean(shannon))

dat.shannon %>%
  ungroup %>%
  mutate(Transect_type = fct_reorder(Transect_type, shannon)) %>% 
  ggplot(aes(x = Transect_type, y = shannon, fill = Transect_type)) + 
  geom_boxplot() + facet_grid(~taxon) +
  scale_x_discrete("") + 
  scale_y_continuous("Shannon index") + 
  scale_fill_discrete("Habitat type") +
  theme_bw() + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggsave("shannon_plot.svg", width = 8, height = 3.5)

for(i in 1:3){
  print(unique(data$taxon)[[i]])
  
  dat.temp <- data %>% filter(taxon == unique(data$taxon)[[i]]) %>% 
    group_by(taxon, Landscape, Transect_type) %>% do(extract_shannon(.))
  
  print(summary(aov(shannon ~ Transect_type, data = dat.temp)))
  
}


anov.tax <- lme4::lmer(shannon ~ taxon + (1|Transect_type), 
                data = dat.shannon)
car::Anova(anov.tax, test.statistic = "F")

pairs(emmeans(anov.tax, ~ taxon))


# NMDS #
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

ggsave("nmds_plot.svg", width = 8, height = 3.5)


# pairwise "
svg("cluster.svg", width = 12, height = 5)

par(mfrow=c(1,3))
plot(hclust(vegdist(data %>% ungroup %>% filter(taxon == "Bumblebees") %>% 
                      group_by(Transect_type, Species) %>% summarise(n = sum(n)) %>%
                      spread(key = Species, value = n) %>% 
                      column_to_rownames("Transect_type")),
            method="single"),
     main = "Bumblebees",
     ylab = "Bray–Curtis distance",
     sub=NA, xlab = NA, cex = 2, cex.main = 2, cex.axis = 1.5, cex.lab = 1.5)


plot(hclust(vegdist(data %>% ungroup %>% filter(taxon == "Butterflies") %>% 
                      group_by(Transect_type, Species) %>% summarise(n = sum(n)) %>%
                      spread(key = Species, value = n) %>% 
                      column_to_rownames("Transect_type")),
            method="single"),
     main = "Butterflies",
     ylab = "Bray–Curtis distance",
     sub=NA, xlab = NA, cex = 2, cex.main = 2, cex.axis = 1.5, cex.lab = 1.5)


plot(hclust(vegdist(data %>% ungroup %>% filter(taxon == "Plants") %>% 
                      group_by(Transect_type, Species) %>% summarise(n = sum(n)) %>%
                      spread(key = Species, value = n) %>% 
                      column_to_rownames("Transect_type")),
            method="single"),
     main = "Plants",
     ylab = "Bray–Curtis distance",
     sub=NA, xlab = NA, cex = 2, cex.main = 2, cex.axis = 1.5, cex.lab = 1.5)

dev.off()


### beta-diversity ###

# by habitat type
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

ggsave("beta.div_plot.svg", width = 8, height = 6)


### test effect of green infra ###
# permanova
# permanova.list <- vector("list", 3)
# n = 0
# for(i in unique(data$taxon)){
#   n = n + 1
#   data.nmds <- data %>% filter(taxon == i, Transect_type != "Powerline") %>% ungroup %>% 
#     dplyr::select(2:8, 11) %>%
#     spread(key = Species, value = n) %>%
#     filter(rowSums(.[,-c(1:5)]) > 0)
#   
#   permanova <- adonis(data.nmds[,-c(1:5)] ~ Transect_type * Powerline * `Road Density` + 
#                         Transect_type * Grasslands, data = data.nmds)
#   permanova.list[[n]] <- permanova
# }
# names(permanova.list) <- unique(data$taxon)

# beta diversity between habitat types depending on powerline and road density
extract_beta_multi <- function(x){
  y <- x %>% ungroup %>% spread(key = Species, value = n) %>% 
    mutate_all(function(x){ifelse(x == 0, 0, 1)})
  b <- beta.multi(y[,-c(1:10)])
  return(as.data.frame(b))
}


beta.by.landscape <- 
  data %>% filter(Transect_type != "Powerline") %>% 
  group_by(taxon, Landscape) %>% 
  do(extract_beta_multi(.)) %>%
  left_join(unique(data[,c(2,7,8,11)])) %>%
  rename(Road_density = `Road Density`)

beta.by.landscape %>% group_by(taxon, Road_density, Powerline) %>% summarise(n = n())

beta.by.landscape %>% group_by(taxon, Road_density, Powerline) %>% 
  summarise(beta.SIM = mean(beta.SIM),
            beta.SNE = mean(beta.SNE),
            beta.SOR = mean(beta.SOR)) %>%
  gather(-1,-2,-3, value = "mean.beta", key = "type") %>%
  left_join(
    beta.by.landscape %>% group_by(taxon, Road_density, Powerline) %>% 
      summarise(beta.SIM = plotrix::std.error(beta.SIM),
                beta.SNE = plotrix::std.error(beta.SNE),
                beta.SOR = plotrix::std.error(beta.SOR)) %>%
      gather(-1,-2,-3, value = "se.beta", key = "type")
  ) %>%
  mutate(type = factor(type, levels = c("beta.SOR", "beta.SIM", "beta.SNE"))) %>%
  ggplot(aes(y = mean.beta, x = Powerline, color = Road_density)) + 
  geom_point(size = 3, position = position_dodge(width = .2)) +
  geom_line(aes(group = Road_density), position = position_dodge(width = .2)) +
  geom_errorbar(aes(ymin = mean.beta - se.beta, ymax = mean.beta + se.beta), width = 0, position = position_dodge(width = .2)) +
  facet_grid(type ~ taxon, scale = "free", 
             labeller = labeller(type = beta.labs)) +
  scale_x_discrete("Presence of powerline") + 
  scale_y_continuous("Beta-diversity") +
  scale_color_discrete("Road density") +
  theme_bw()

ggsave("beta.by.landscape_plot.svg", width = 8, height = 6)

for(i in 1:3){
  print(unique(data$taxon)[[i]])
  
  dat.temp <- beta.by.landscape %>% filter(taxon == unique(data$taxon)[[i]])
  # # step 0: powerline only
  # print(summary(lm(beta.SOR ~ Powerline, 
  #                  data = beta.by.landscape %>% filter(taxon == unique(data$taxon)[[i]]))))
  # 
  # # step 1: powerline and road density only
  # print(summary(lm(beta.SOR ~ Powerline * Road_density, 
  #            data = beta.by.landscape %>% filter(taxon == unique(data$taxon)[[i]]))))
  
  # step 2: considering grassland area as well
  test.beta.by.landscape <- lm(beta.SOR ~ Powerline * Road_density * Grasslands, 
                               data = dat.temp, na.action = na.fail)
  print(summary(test.beta.by.landscape))
}


beta.by.landscape %>% filter(taxon == "Bumblebees") %>% pull(Grasslands) %>% hist
quantile(beta.by.landscape %>% filter(taxon == "Bumblebees") %>% pull(Grasslands), probs = c(.1,.25,.5,.75))

test.beta.by.landscape_BB <- lm(beta.SOR ~ Powerline * Road_density * Grasslands, 
                                data = beta.by.landscape %>% filter(taxon == "Bumblebees"))


dat1 <- (visreg(test.beta.by.landscape_BB, xvar = "Powerline", by = "Road_density", 
                cond = list(Grasslands = 0.013), plot = F))$fit
dat2 <- (visreg(test.beta.by.landscape_BB, xvar = "Powerline", by = "Road_density", 
                cond = list(Grasslands = 0.025), plot = F))$fit
dat3 <- (visreg(test.beta.by.landscape_BB, xvar = "Powerline", by = "Road_density", 
                cond = list(Grasslands = 0.041), plot = F))$fit

bind_rows(Low = dat1, Medium = dat2, High = dat3, .id = "Grassland cover") %>%
  mutate(`Grassland cover`  = factor(`Grassland cover`, levels = c("Low", "Medium", "High"))) %>%
  ggplot(aes(y = visregFit, x = Powerline, color = Road_density)) + 
  geom_point(size = 3, position = position_dodge(width = .2)) +
  geom_line(aes(group = Road_density), position = position_dodge(width = .2)) +
  geom_errorbar(aes(ymin = visregLwr, ymax = visregUpr), width = 0, position = position_dodge(width = .2)) +
  facet_grid( ~ `Grassland cover`, scale = "free") +
  scale_x_discrete("Presence of powerline") + 
  scale_y_continuous("Beta-diversity") +
  scale_color_discrete("Road density") +
  theme_bw()

pairs(emmeans(test.beta.by.landscape_BB, ~ Road_density | Powerline, at = list(Grasslands = 0.013)))
pairs(emmeans(test.beta.by.landscape_BB, ~ Road_density | Powerline, at = list(Grasslands = 0.041)))

pairs(emmeans(test.beta.by.landscape_BB, ~ Powerline | Road_density, at = list(Grasslands = 0.011)))
pairs(emmeans(test.beta.by.landscape_BB, ~ Powerline | Road_density, at = list(Grasslands = 0.013)))
pairs(emmeans(test.beta.by.landscape_BB, ~ Powerline | Road_density, at = list(Grasslands = 0.025)))
pairs(emmeans(test.beta.by.landscape_BB, ~ Powerline | Road_density, at = list(Grasslands = 0.041)))

# beta diversity between landscape types depending on powerline and road density
library(dendextend)

data.by.landscape <- data %>% filter(Transect_type != "Powerline") %>% 
  group_by(taxon, Landscape, Species) %>% 
  summarise(n = sum(n))


dend <- as.dendrogram(hclust(vegdist(data %>% ungroup %>% filter(taxon == "Bumblebees", Transect_type != "Powerline") %>% 
                                       group_by(Landscape, Species) %>% summarise(n = sum(n)) %>%
                                       spread(key = Species, value = n) %>% ungroup %>%
                                       column_to_rownames("Landscape")),
                             method="single"))

colors_to_use <- data %>% group_by(Landscape) %>% 
  summarise(Landscape_type = unique(`Landscape type`)) %>% 
  pull(Landscape_type)
colors_to_use <- as.factor(colors_to_use)
levels(colors_to_use) <- 1:4
colors_to_use <- colors_to_use[order.dendrogram(dend)]
labels_colors(dend) <- as.numeric(colors_to_use)
plot(dend)

#######################
## clean environment ##
#######################
gdata::keep(data, 
            dat.shannon,
            ndms.plots,
            beta.by.landscape,
            sure = T)



