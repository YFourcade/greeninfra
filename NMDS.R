library(tidyverse)
library(vegan)
library(patchwork)
library(ggalt)
library(ggh4x)

### import data ###
site_data <- read.csv2("../Data/database.PD.taxalabels.csv")
coords <- read_csv2("../Data/Centroid_coords.csv") %>% 
  mutate(Transect_type = ifelse(Transect_type == "Field border", "Between fields", Transect_type),
         Transect_type = ifelse(Transect_type == "Power line", "Powerline", Transect_type))

data_BB <- read_csv2("../Data/bb.tidy.csv")
data_But <- read_csv2("../Data/bf.tidy.csv")
data_Plants <- read_csv2("../Data/pp.tidy.csv") %>% 
  group_by(Landscape, Transect_type, Species) %>%
  summarise(Indiv = length(Plot), Category = unique(Category))

data <- bind_rows("Bumblebees" = data_BB, "Butterflies" = data_But, "Plants" = data_Plants, 
                  .id = "taxon") %>% 
  separate(Category, sep = "\\.", into = c("Powerline", "Road density")) %>% 
  mutate(Powerline = ifelse(Powerline == "PL", "Yes", "No"),
         `Road density` =ifelse(`Road density` == 'LRD', "Low", "High"))


### NMDS ###
ndms.plots <- c()
nmds.stress <- c()
for(i in unique(data$taxon)){
  
  # select data
  data.nmds <- data %>% filter(taxon == i) %>% 
    select(taxon, Landscape, Transect_type, Species, Indiv) %>% 
    pivot_wider(names_from = Species, values_from = Indiv, values_fill = 0) %>% 
    left_join(site_data)
  
  # NMDS
  nmds <- metaMDS(data.nmds[,-c(1:3, (ncol(data.nmds)-19):ncol(data.nmds))], 
                  maxit = 20000,
                  maxtry = 100,
                  k= 3,
                  trace = 0)
  print(paste("Taxon:",i, "; Stress =", nmds$stress))
  
  # prepare scores
  nmds.scores <- as.data.frame(scores(nmds)$sites)
  nmds.scores$site <- rownames(nmds.scores)
  nmds.scores$habitat <- factor(data.nmds$Transect_type, levels = trans_type)
  nmds.scores$RD <- data.nmds$RD
  nmds.scores$TUVA <- data.nmds$TUVA
  
  # merge data
  ndms.plots <- rbind.data.frame(
    ndms.plots, 
    cbind.data.frame(
      taxon = i,
      nmds.scores
    )
  )
  nmds.stress <- rbind.data.frame(
    nmds.stress,
    cbind.data.frame(taxon = i, stress = nmds$stress)
  )
}

### Plots             ###
### Don't freak out ! ###

# Bumblebees
p1 <- ggplot(
  data = 
    bind_rows(
      ndms.plots %>% filter(taxon == "Bumblebees") %>% 
        select(NMDS1,NMDS2, habitat) %>% 
        rename(x = NMDS2, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS2", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Bumblebees") %>% 
        select(NMDS1,NMDS3, habitat) %>% 
        rename(x = NMDS3, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Bumblebees") %>% 
        select(NMDS3,NMDS2, habitat) %>% 
        rename(x = NMDS3, y = NMDS2) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS2")
    ), # prepare data for showing all three dimensions
  aes(x=x,y=y,shape=habitat,colour=habitat)
) +
  geom_point() + # points
  geom_encircle(
    aes(fill = habitat),
    alpha=0.25,
    s_shape = 1,
    expand = 0,
    spread = 0
  ) + # polygons showing habitat types
  facet_manual(
    Axis_x~Axis_y,  
    design = matrix(c(1,NA,2,3), ncol = 2), 
    respect = T, 
    axes = "all",
    strip = strip_split(
      position = c("bottom", "left"),
      text_y = list(element_text(),element_text(color = "white"))
    )
  ) +
  theme_classic() +
  scale_y_continuous("") + 
  scale_x_continuous("") +
  theme(legend.position = c(.2, .2),
        legend.title= element_blank(),
        panel.background = element_rect(colour = 'black'),
        strip.background = element_blank(),
        strip.placement = "outside") +
  ggtitle("Bumblebees", subtitle = paste("Stress =", round(nmds.stress[1,2],2)))

# Butterflies
p2 <- ggplot(
  data = 
    bind_rows(
      ndms.plots %>% filter(taxon == "Butterflies") %>% 
        select(NMDS1,NMDS2, habitat) %>% 
        rename(x = NMDS2, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS2", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Butterflies") %>% 
        select(NMDS1,NMDS3, habitat) %>% 
        rename(x = NMDS3, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Butterflies") %>% 
        select(NMDS3,NMDS2, habitat) %>% 
        rename(x = NMDS3, y = NMDS2) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS2")
    ),
  aes(x=x,y=y,shape=habitat,colour=habitat)
) +
  geom_point() +
  geom_encircle(
    aes(fill = habitat),
    alpha=0.25,
    s_shape = 1,
    expand = 0,
    spread = 0
  ) +
  facet_manual(
    Axis_x~Axis_y,  
    design = matrix(c(1,NA,2,3), ncol = 2), 
    respect = T, 
    axes = "all",
    strip = strip_split(
      position = c("bottom", "left"),
      text_y = list(element_text(),element_text(color = "white"))
    )
  ) +
  theme_classic() +
  scale_y_continuous("") + 
  scale_x_continuous("") +
  theme(legend.position = "none",
        legend.title= element_blank(),
        panel.background = element_rect(colour = 'black'),
        strip.background = element_blank(),
        strip.placement = "outside") +
  ggtitle("Butterflies", subtitle = paste("Stress =", round(nmds.stress[2,2],2)))

# Plants
p3 <- ggplot(
  data = 
    bind_rows(
      ndms.plots %>% filter(taxon == "Plants") %>% 
        select(NMDS1,NMDS2, habitat) %>% 
        rename(x = NMDS2, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS2", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Plants") %>% 
        select(NMDS1,NMDS3, habitat) %>% 
        rename(x = NMDS3, y = NMDS1) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS1"),
      ndms.plots %>% filter(taxon == "Plants") %>% 
        select(NMDS3,NMDS2, habitat) %>% 
        rename(x = NMDS3, y = NMDS2) %>% 
        mutate(Axis_x = "NMDS3", Axis_y = "NMDS2")
    ),
  aes(x=x,y=y,shape=habitat,colour=habitat)
) +
  geom_point() +
  geom_encircle(
    aes(fill = habitat),
    alpha=0.25,
    s_shape = 1,
    expand = 0,
    spread = 0
  ) +
  facet_manual(
    Axis_x~Axis_y,  
    design = matrix(c(1,NA,2,3), ncol = 2), 
    respect = T, 
    axes = "all",
    strip = strip_split(
      position = c("bottom", "left"),
      text_y = list(element_text(),element_text(color = "white"))
    )
  ) +
  theme_classic() +
  scale_y_continuous("") + 
  scale_x_continuous("") +
  theme(legend.position = "none",
        legend.title= element_blank(),
        panel.background = element_rect(colour = 'black'),
        strip.background = element_blank(),
        strip.placement = "outside") +
  ggtitle("Plants", subtitle = paste("Stress =", round(nmds.stress[3,2],2)))

p.hab <- p1 + p2 + p3
p.hab

# save
ggsave2("plot.nmds.pdf", p.hab, width = 15, height = 6)
