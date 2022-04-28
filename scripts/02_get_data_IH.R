# Download biological data

rm(list=ls())

# Load the packages to be used
install.packages('rgbif') # GBIF data download
install.packages('robis') # OBIS data download
install.packages('mapr') # To map GBIF points
install.packages('raster') # Raster operations
install.packages('rgdal') # Raster operations
install.packages('sdmpredictors') # Bio-Oracle and Marspec data download
install.packages('tidyverse') # Data management

library(rgbif)
library(robis)
library(mapr)
library(raster)
library(rgdal)
library(sdmpredictors)
library(tidyverse)
library(dplyr)

# To establish working directory
#setwd('')
# PREGUNTAR A SALVA COMO HACERLO PARA QUE NO SEA UN DIRECTORIO DEL ORDENADOR

################# GBIF PRESENCES DOWNOLOAD ##################
# http://www.gbif.org/species
# To download GBIF data with geographic information
Asparagopsis_gbif_raw<-occ_search(scientificName = "Asparagopsis armata",
                               basisOfRecord = "HUMAN_OBSERVATION",
                               return='data', hasCoordinate = T,
                               fields=c('genus','decimalLatitude','decimalLongitude'))

# Columns names are renamed for homogenization
Asparagopsis_gbif <- as.data.frame(Asparagopsis_gbif_raw$data)
colnames(Asparagopsis_gbif)<-c("name","longitude","latitude")

# To visualize data
map_leaflet(Asparagopsis_gbif, size = 10)
rm(Asparagopsis_gbif_raw)

# http://www.iobis.org/
# It just can filtered by date and depth
Asparagopsis_obis_raw<- as.data.frame(occurrence("Asparagopsis armata"))

# We filter the dataframe
Asparagopsis_obis <- dplyr::select(Asparagopsis_obis_raw, genus,
                         decimalLongitude, decimalLatitude)
colnames(Asparagopsis_obis)<-c("name","longitude","latitude")

# To visualize data
map_leaflet(Asparagopsis_obis)
rm(Asparagopsis_obis_raw)

# We combine data from GBIF and OBIS
Asparagopsis <- rbind(Asparagopsis_gbif,Asparagopsis_obis)
rm(Asparagopsis_gbif,Asparagopsis_obis)

# To eliminate duplicates and NA
dups <- duplicated(Asparagopsis)
Asparagopsis <-  Asparagopsis[!dups, ]
Asparagopsis <-  na.omit(Asparagopsis)
rm(dups)

# To combine data of several species
# Especies <- rbind(Posidonia, Caulerpa)

# To save data in .csv to use in MAxent
#### Ver con Salva como hacerlo sin directorios
dir.create("./Datos/entrada")
dir.create("./Datos/entrada/biologicos")
write.csv(Asparagopsis, file="./Datos/entrada/biologicos/Asparagopsis.CSV",
          row.names=FALSE)


################ HISTORICAL DATA DOWNLOAD FROM BIO-ORACLE AND MARSPEC ##################
# http://bio-oracle.org/ & http://www.marspec.org/
# To explore available information
marine_datasets <- list_datasets(terrestrial = FALSE, marine = TRUE)
mar_layers <- list_layers(marine_datasets)

# Download salinity, SST max, SST average, SST range, pH and bathymetry
dir.create("./Datos/entrada/ambientales") # PREGUNTAR A SALVA COMO HACER PARA NO UTILIZAR DIRECTORIOS DE CARPETAS
dir.create("./Datos/entrada/ambientales/Historicos")
var_hist <- load_layers(layercodes = c("BO_salinity","BO_sstmax","BO_sstmin","BO_sstmean", "BO_sstrange",
                                       "MS_bathy_5m","BO_parmax","BO_parmean","BO_phosphate","BO_nitrate"),
                        datadir = "./Datos/entrada/ambientales/Historicos",
                        rasterstack=FALSE)

# To save as ascii
nombres<-names(var_hist)
i=1
for (i in 1:length(var_hist@layers))
{
  outname <- paste("./Datos/entrada/ambientales/Historicos/", nombres[i], ".asc", sep = "")
  writeRaster(var_hist[[i]], outname, format = "ascii", overwrite=TRUE)
}
rm(nombres)

# # Se recortan las variables con la zona  de estudio y se guardan como ascii
# dir.create("./Datos/entrada/ambientales/Historicos/Med")
# e = extent( -10, 35, 30, 46)
# nombres<-names(var_hist)
# i=1
# for (i in 1:length(var_hist@layers))
# {
#   a <- crop(var_hist[[i]], e, keepres=TRUE)
#   outname <- paste("./Datos/entrada/ambientales/Historicos/Med/", nombres[i],
#                    ".asc", sep = "")
#   writeRaster(a, outname, format = "ascii", overwrite=TRUE)
#   rm(a)
# }
# rm(nombres)

########### DOWNLOAD PROJECTED BIO-ORACLE DATA ############
# Marine information available
futuro <- list_layers_future(marine = T,datasets = "Bio-ORACLE") # Available information in future scenarios
# Available scenarios
unique(futuro$scenario)

# To extract information about future scenario and to save
name_RCP85_2100 <- get_future_layers(c("BO2_salinitymean_ss","BO2_tempmax_ss",
                                       "BO2_tempmean_ss", "BO21_temprange_ss"),
                                     scenario = "RCP85", year = 2100)$layer_code
dir.create("./Datos/entrada/ambientales/Proyectados")
var_RCP85_2100 <- load_layers(name_RCP85_2100, rasterstack = T,
                              datadir = "./Datos/entrada/ambientales/Proyectados")

# To save as ascii
nombres<-names(var_RCP85_2100)
i=1
for (i in 1:length(var_RCP85_2100@layers))
{
  outname <- paste("./Datos/entrada/ambientales/Proyectados/", nombres[i], ".asc", sep = "")
  writeRaster(var_RCP85_2100[[i]], outname, format = "ascii", overwrite=TRUE)
}
rm(nombres)

# # Se recortan las variables con la zona  de estudio y se guardan como ascii
# dir.create("./Datos/entrada/ambientales/Proyectados/Med")
# nombres<-names(var_RCP85_2100)
# i=1
# for (i in 1:length(var_RCP85_2100@layers))
# {
#   a <- crop(var_RCP85_2100[[i]],e,keepres=TRUE)
#   outname <- paste("./Datos/entrada/ambientales/Proyectados/Med/", nombres[i],
#                    ".asc", sep = "")
#   writeRaster(a, outname, format = "ascii", overwrite=TRUE)
#   rm(a)
# }
# rm(nombres, e)

dir.create("./Datos/salida")
