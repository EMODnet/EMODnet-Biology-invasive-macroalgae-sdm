rm(list=ls())

library(raster)
library(ggplot2)
library(dplyr)
library(sp)
library(rgdal)
library(sf)
library(viridis)
library(ggpubr)
library(RColorBrewer)


setwd("D:/Proyectos/EMODNET/data/analysis/kuenm_Aspargopsis")


basemap <- st_read("D:/Modelado/Modelos/GIS/Countries_WGS84/Countries_WGS84.shp")
basemap <- st_crop(basemap, xmin = -25, ymin = 0, xmax = 45,  ymax = 75)
summary(basemap)

test_points <- read.csv("./Aspargopsis_test.csv")
test_points$type <- "Test"
train_points <- read.csv("./Aspargopsis_train.csv")
train_points$type <- "Train"
presences <- rbind(train_points, test_points)



SDM <- raster("./Final_Models/M_0.9_F_t_Set_23_EC/Aspargopsis_avg.asc")
SDM_projected <- raster("./Final_Models/M_0.9_F_t_Set_23_EC/Aspargopsis_RCP85_avg.asc")
SDM_diff <- SDM_projected - SDM

SDM_df <- na.omit(as.data.frame(SDM, xy = TRUE))
SDM_df <- SDM_df %>% mutate(across(c(x, y, Aspargopsis_avg), round, digits = 5))
SDM_projected_df <- na.omit(as.data.frame(SDM_projected, xy = TRUE))
SDM_projected_df <- SDM_projected_df %>% mutate(across(c(x, y, Aspargopsis_RCP85_avg), round, digits = 5))
SDM_diff_df <- na.omit(as.data.frame(SDM_diff, xy = TRUE))
SDM_diff_df <- SDM_diff_df %>% mutate(across(c(x, y, layer), round, digits = 5))


SDM_map <- ggplot(data = SDM_df) +
                  geom_raster(aes(x = x, y = y, fill = Aspargopsis_avg)) +
                  labs(x = 'Longitude', y = 'Latitude', fill = "Habitat Suitability") +
                  scale_fill_distiller(palette = "Spectral") +
                  scale_shape_manual(values=c(15, 17))+
                  scale_color_manual(values=c('brown1','chocolate'))+
                  theme_bw() +
                  theme(legend.position = "bottom")
SDM_map

map_1 <- ggplot(basemap) +
  geom_sf(size = .1)+
  geom_point(data=presences, aes(x=longitude, y=latitude, color = type)) +
  labs(title = "Species Presence Points", y = "Latitude", x = "Longitude", color = "   Occurrence Data   ") +
  coord_sf(expand = F, xlim = c(-25, 45), ylim = c(25, 75)) +
  theme_bw() +
  theme(legend.position = "right",
        plot.margin = margin(t = 5,  r = 5, b = 5, l = 5),
        panel.spacing=unit(1.5, "lines"),
        plot.title = element_text(size = 28, face = "bold", hjust = 0.5),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.text = element_text(size = 24),
        legend.title = element_text(size = 24),
        legend.background = element_rect(color="black"),
        legend.key.width = unit(1, "cm"),
        legend.key.height = unit(2, "cm"),
        legend.margin =margin(r=30,l=20,t=20,b=20))
  

map_1

map_2 <- ggplot(basemap) +
  geom_tile(data = SDM_df, aes(x = x, y = y, fill = Aspargopsis_avg)) +
  geom_sf(size = .1)+
  labs(title = "Historical Potential Distribution", y = "Latitude", x = "Longitude", fill = " Habitat  Suitability ") +
  scale_fill_viridis(option = "C", breaks = c(seq(0,1, by = 0.2)), limits = c(0,1)) +
  coord_sf(expand = F, xlim = c(-25, 45), ylim = c(25, 75)) +
  theme_bw() +
  theme(legend.position = "right",
        plot.margin = margin(t = 5,  r = 5, b = 5, l = 5),
        panel.spacing=unit(1.5, "lines"),
        plot.title = element_text(size = 28, face = "bold", hjust = 0.5),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 24),
        legend.background = element_rect(color="black"),
        legend.key.width = unit(1, "cm"),
        legend.key.height = unit(2, "cm"),
        legend.margin =margin(r=30,l=20,t=20,b=20)) +
  guides(fill = guide_colorbar(draw.ulim = F, draw.llim = F))

map_2

map_3 <- ggplot(basemap) +
  geom_tile(data = SDM_projected_df, aes(x = x, y = y, fill = Aspargopsis_RCP85_avg)) +
  geom_sf(size = .1)+
  labs(title = "Projected Potential Distribution", y = "Latitude", x = "Longitude", fill = " Habitat  Suitability ") +
  scale_fill_viridis(option = "C", breaks = c(seq(0,1, by = 0.2)), limits = c(0,1)) +
  coord_sf(expand = F, xlim = c(-25, 45), ylim = c(25, 75)) +
  theme_bw() +
  theme(legend.position = "right",
        plot.margin = margin(t = 5,  r = 5, b = 5, l = 5),
        panel.spacing=unit(1.5, "lines"),
        plot.title = element_text(size = 28, face = "bold", hjust = 0.5),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 24),
        legend.background = element_rect(color="black"),
        legend.key.width = unit(1, "cm"),
        legend.key.height = unit(2, "cm"),
        legend.margin =margin(r=30,l=20,t=20,b=20)) +
  guides(fill = guide_colorbar(draw.ulim = F, draw.llim = F))

map_3

map_4 <- ggplot(basemap) +
  geom_tile(data = SDM_diff_df, aes(x = x, y = y, fill = layer)) +
  geom_sf(size = .1)+
  labs(title = "Change in Potential Distribution", y = "Latitude", x = "Longitude", fill = expression(paste(Delta, " Habitat Suitability"))) +
  scale_fill_gradient2(
    low = "#990000", 
    mid = "#FFFFCC", 
    high = "#339933", 
    midpoint = 0,
    breaks = c(seq(-0.8,0.8, by = 0.2)), limits = c(-0.8,0.8)) +
  coord_sf(expand = F, xlim = c(-25, 45), ylim = c(25, 75)) +
  theme_bw() +
  theme(legend.position = "right",
        plot.margin = margin(t = 5,  r = 5, b = 5, l = 5),
        panel.spacing=unit(1.5, "lines"),
        plot.title = element_text(size = 28, face = "bold", hjust = 0.5),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        axis.title.x = element_text(size = 24),
        axis.title.y = element_text(size = 24),
        legend.text = element_text(size = 18),
        legend.title = element_text(size = 24),
        legend.background = element_rect(color="black"),
        legend.key.width = unit(1, "cm"),
        legend.key.height = unit(2, "cm"),
        legend.margin =margin(r=30,l=20,t=20,b=20)) +
  guides(fill = guide_colorbar(draw.ulim = F, draw.llim = F))
    

map_4
dev.off()


figure <- ggarrange(map_2,map_1,map_3,map_4, ncol = 2, nrow = 2, align = "hv")
figure

ggsave(filename = "Asparagopsis_Results.tiff", plot = figure, path = "./Graphs", dpi=600, width=30, height=27.5, unit="in", bg = "white")                      
