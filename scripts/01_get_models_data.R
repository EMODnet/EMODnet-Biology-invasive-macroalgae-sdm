install.packages("worrms")
devtools::install_github("lifewatch/eurobis")
devtools::install_github("vlizBE/imis")
devtools::install_github("EMODnet/EMODnetWFS")
devtools::install_github("eblondel/ows4R")
install.packages('rgbif')
install.packages('robis')
install.packages('mapr')
install.packages('raster')
install.packages('rgdal')
install.packages('sdmpredictors')
install.packages('tidyverse')
install.packages("spocc", dependencies = TRUE)
install.packages("leaflet")
install.packages("leaflet.extras")
install.packages("stars")


library(worrms)
library(mregions)
library(eurobis)
library(EMODnetWFS)
library(mapview)
library(sf)
library(rgbif)
library(robis)
library(mapr)
library(raster)
library(rgdal)
library(sdmpredictors)
library(tidyverse)
library(dplyr)
library(spocc)
library(leaflet)
library(leaflet.extras)
library(stars)


#### WORKING DIRECTORY ####
setwd("D:/Proyectos/EMODNET")

#### ENVIRONMENTAL DATA ####
# HISTORICAL DATA DOWNLOAD FROM BIO-ORACLE
# http://bio-oracle.org/
# To explore available information
mar_layers <- list_layers(list_datasets(terrestrial = FALSE, marine = TRUE))

# Download historical SST average, SST range, Salinity maximum, phosphates, Kd and PAR maximum for version 2.2
var_hist <- load_layers(layercodes = c("BO22_tempmean_bdmax", "BO22_temprange_bdmax", "BO22_salinitymax_bdmax",
                                       "BO22_phosphatemean_bdmax", "BO22_damean", "BO22_parmax"),
                        datadir = "./data/raw_data/env/hist",
                        rasterstack=FALSE)
rm(var_hist)


# BATHYMETRY
# R DOWNLOAD IS NOT AVAILABLE. DOWNLOAD MANUALLY BATHYMETRY FROM EMODNET AND SAVE IT IN THE SAME DIRECTORY ("./data/raw_data/env/hist")
# https://tiles.emodnet-bathymetry.eu/
# Load bathymethry 
batiraw <- raster("./data/raw_data/env/hist/Emodnet_2020.nc")
plot(batiraw)
# writeRaster(x = batiraw, filename = './data/raw_data/env/hist/Bathymetry/Emodnet2020.tif', format = 'GTiff', overwrite = TRUE) #Conversion from .nc file to .tif file if interested

# To continue, unzip manually downloaded layers in your folder
# Load environmental layers from your directory
list <- list.files(path="./data/raw_data/env/hist", pattern='.tif$', full.names=TRUE)
var_hist_BO <- brick(stack(list)) # Formal class RasterBrick
save(var_hist_BO,file="./data/var_hist_BO.Rda")
rm(list)


# compare extension of study area and bio-oracle variables
extent20M <- Which(batiraw > -20 & batiraw < 0, cells = FALSE)
extent(extent20M)
extent(var_hist_BO[[1]])
# compare resolution
xres(extent20M) # 0.001041667
xres(var_hist_BO[[1]]) # 0.08333333
# Homogeneize extension to the Emodnet area and resolution to BO variables
var_hist_BO <- crop(var_hist_BO, extent(extent20M), keepres=TRUE)
mask20m <- resample(x=extent20M, y=var_hist_BO[[1]], method="bilinear")
xres(mask20m) # 0.08333333
bathy <- resample(x=batiraw, y=mask20m, method="bilinear")
bathymetry <- mask20m*bathy
var_hist <- stack(var_hist_BO,bathymetry)
mask20m[mask20m == 0] <- NA
NAvalues <- mask20m*var_hist # To propagate NA values
plot(NAvalues)
var_hist <- mask(var_hist, NAvalues)

n <-names(var_hist)
n[7] <- "bathymetry"
dir.create("./data/derived_data/env/hist", recursive = TRUE)
i=1
for (i in 1:nlayers(var_hist))
{
  a <- var_hist[[i]]
  outname <- paste("./data/derived_data/env/hist/", n[i],
                   ".asc", sep = "")
  writeRaster(a, outname, format = "ascii", overwrite=TRUE)
  rm(a)
}
rm(n,outname, batiraw, extent20m,bathy)

# CLIMATE CHANGE ENVIRONMENTAL INFORMATION
futur <- list_layers_future(marine = T,datasets = "Bio-ORACLE")
name_RCP85_2100 <- get_future_layers(c("BO22_salinitymax_bdmax","BO22_tempmean_bdmax","BO22_temprange_bdmax"),
                                     scenario = "RCP85", year = 2100)$layer_code
var_RCP85_BO <- load_layers(name_RCP85_2100, rasterstack = T,
                             datadir = "./data/raw_data/env/RCP85")
# Unzip layers in folder
# list <- list.files(path="./data/raw_data/env/RCP85", pattern='.tif$', full.names=TRUE)
# var_RCP85_BO <- brick(stack(list)) # Formal class RasterBrick
save(var_RCP85_BO,file="./data/var_RCP85_BO.Rda")

var_RCP85_BO <- crop(var_RCP85_BO, extent(mask20m), keepres=TRUE)
NAvalues <- mask20m*var_RCP85_BO
var_RCP85_BO <- mask(var_RCP85_BO, NAvalues)
n <-names(var_hist) #To project with kuenm it is necessary that historic layer names match projected layer names
dir.create("./data/derived_data/env/RCP85", recursive = TRUE)
i=1
for (i in 1:nlayers(var_RCP85_BO))
{
  a <- var_RCP85_BO[[i]]
  outname <- paste("./data/derived_data/env/RCP85/", n[i],
                   ".asc", sep = "")
  writeRaster(a, outname, format = "ascii", overwrite=TRUE)
  rm(a)
}
rm(n,outname)

# Variables that stay constant are pasted manually from the historical folder to the RCP85 folder

#### OCCURRENCE DATA #####
# Get species AphiaID using WoRMS
species_list <- c("Asparagopsis armata", "Sargassum muticum", "Caulerpa taxifolia", "Undaria pinnatifida")
species_match <- worrms::wm_records_taxamatch(species_list)
species_match <- do.call(rbind, species_match)

print(species_match$valid_AphiaID)
#> [1] 144438 494791 144476 145721
#>

occ.Emodnet <- setNames(data.frame(matrix(ncol = 3, nrow = 1)), c('name','longitude','latitude'))
i=1
for (i in 1:length(species_list))
{
  url1 <-"http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=context%3A0100%3Baphiaid%3A"
  url2 <-"&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv"
  urlEmodnet <- paste(url1, species_match$valid_AphiaID[i], url2)
  temp.Emodnet <- read.csv(url(urlEmodnet))
  temp.Emodnet <- dplyr::select(temp.Emodnet, scientificname, decimallongitude, decimallatitude)
  colnames(temp.Emodnet)<-c("name","longitude","latitude")
  occ.Emodnet <- bind_rows(occ.Emodnet, temp.Emodnet)
  rm(temp.Emodnet,url1,url2,urlEmodnet)
}
occ.Emodnet <- occ.Emodnet[-c(1), ]
unique(occ.Emodnet$name)
# [1] "Asparagopsis armata"                      "Falkenbergia rufolanosa"
# [3] "Polysiphonia rufolanosa"                  "Falkenbergia rufolanosa - stadium"
# [5] "Sargassum (Bactrophycus) Teretia muticum" "Sargassum muticum"
# [7] "Sargassum (Bactrophycus) muticum"         "Sargassum muticum (Yendo) Fensholt"
# [9] "Sargassum muticum (Yendo) Fensholt, 1955" "Caulerpa taxifolia"
# [11] "Undaria pinnatifida"                      "Undaria pinnatifida var. elongata"
# [13] "Undaria pinnatifida var. vulgaris"

occ.gbif.obis <- setNames(data.frame(matrix(ncol = 3, nrow = 1)), c('name','longitude','latitude'))
i=1
for(i in 1:length(species_list)) {
  didwarn <- tryCatch({occ(query = species_list[i], from = c('gbif','obis')); FALSE}, warning = function(w) return(TRUE))
  if(didwarn) {
    print(paste("no data", species_list[i]))
    next
  }
  else {
    temp.gbif.obis <-occ(query = species_list[i], from = c('gbif','obis'))
    temp.gbif.obis <- dplyr::select(occ2df(temp.gbif.obis), name, longitude, latitude)
    occ.gbif.obis <- bind_rows(occ.gbif.obis, temp.gbif.obis)
    rm(temp.gbif.obis)
  }
}
occ.gbif.obis <- occ.gbif.obis[-c(1), ]
# [1] "no data Asparagopsis armata"
unique(occ.gbif.obis$name)
# [1] "Sargassum muticum (Yendo) Fensholt"                    "Sargassum muticum"
# [3] "Caulerpa taxifolia (M.Vahl) C.Agardh"                  "Caulerpa taxifolia f. tristichophylla Svedelius, 1906"
# [5] "Caulerpa taxifolia"                                    "Caulerpa taxifolia var. distichophylla"
# [7] "Caulerpa taxifolia f. tristichophylla"                 "Undaria pinnatifida (Harv.) Suringar"
# [9] "Undaria pinnatifida"

occurrences <- rbind(occ.Emodnet,occ.gbif.obis)
rm(occ.Emodnet,occ.gbif.obis)
# Homogenize species names
occurrences <- occurrences %>%
  mutate(name = case_when((name == 'Asparagopsis armata') | (name == 'Polysiphonia rufolanosa') |
                            (name == 'Falkenbergia rufolanosa') | (name == 'Falkenbergia rufolanosa - stadium')
                          ~ 'Asparagopsis',
                          (name == 'Sargassum muticum') | (name == 'Sargassum (Bactrophycus) Teretia muticum') |
                            (name == 'Sargassum (Bactrophycus) muticum') | (name == 'Sargassum muticum (Yendo) Fensholt') |
                            (name == 'Sargassum muticum (Yendo) Fensholt, 1955') | (name == 'Sargassum muticum (Yendo) Fensholt')
                          ~ 'Sargassum',
                          (name == 'Caulerpa taxifolia') | (name == 'Caulerpa taxifolia (M.Vahl) C.Agardh') |
                            (name == 'Caulerpa taxifolia f. tristichophylla Svedelius, 1906') |
                            (name == 'Caulerpa taxifolia var. distichophylla') | (name == 'Caulerpa taxifolia f. tristichophylla')
                          ~ 'Caulerpa',
                          (name == 'Undaria pinnatifida') | (name == 'Undaria pinnatifida var. elongata') |
                            (name == 'Undaria pinnatifida var. vulgaris') | (name == 'Undaria pinnatifida (Harv.) Suringar')
                          ~ 'Undaria'))
unique(occurrences$name)
# [1] "Asparagopsis" "Sargassum"   "Caulerpa"    "Undaria"

# Remove duplicated occurrences
dups <- duplicated(occurrences)
occurrences <-  occurrences[!dups, ]
occurrences <-  na.omit(occurrences) # From 9093 obs to 5281 obs
rm(dups)

coordinates(occurrences) <- c('longitude','latitude')
crs(occurrences) <- "+proj=longlat +datum=WGS84"
occurrences <- crop(occurrences, extent(var_hist_BO[[1]]), keepres=TRUE)
occurrences <- as.data.frame(occurrences)
names(occurrences) <- c("name", "longitude", "latitude")

save(occurrences,file="./data/occurrences.Rda")
dir.create("./data/derived_data/bio", recursive = TRUE)
write.csv(occurrences, file="./data/derived_data/bio/occurrences.csv", row.names=FALSE)
