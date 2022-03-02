install.packages("worrms")
devtools::install_github("lifewatch/eurobis")
devtools::install_github("vlizBE/imis")
devtools::install_github("EMODnet/EMODnetWFS")
devtools::install_github("eblondel/ows4R")

library(worrms)
library(mregions)
library(eurobis)
library(EMODnetWFS)
library(mapview)
library(sf)

# Get species AphiaID using WoRMS
species_list <- c("Aspargopsis armata", "Sargassum muticum", "Caulerpa taxifolia", "Undaria pinnatifida")
species_match <- worrms::wm_records_taxamatch(species_list)
species_match <- do.call(rbind, species_match)

print(species_match$valid_AphiaID)
#> [1] 144438 494791 144476 145721

# Get overview of records in EMODnet Biology
visualize_species_grid <- function(aphiaid){
  grid <- eurobis::getEurobisGrid(aphiaid, gridsize = "1d")
  mapview::mapview(grid)
}

visualize_species_points <- function(aphiaid){
  grid <- eurobis::getEurobisPoints(aphiaid)
  message(nrow(grid))
  mapview::mapview(grid)
}

# "Sargassum muticum" is the species with more records in eurobis
visualize_species_grid(494791)
visualize_species_points(494791)

View(IHOareas)

# Get spatial extent from MarineRegions
list_mrgid <- read.table(here::here("data", "derived_data", "list_mrgid.txt"), header = TRUE)[,1]
path_eez_iho <- mr_shp(key = "MarineRegions:eez_iho", maxFeatures = 1000, read = FALSE, overwrite = TRUE)
eez_iho <- st_read(path_eez_iho,
                   query = glue::glue("SELECT *
                                      FROM \"eez_iho\"
                                      WHERE mrgid IN ({paste0(list_mrgid, collapse = \", \")})"))

eez_iho_bbox <- st_bbox(eez_iho)

# Get data
occurrences <- getEurobisData(aphiaid = 494791, mrgid = list_mrgid, type = "basic")
occurrences_spatial <- st_as_sf(occurrences$data, coords = c("decimallongitude", "decimallatitude"), crs = 4326)
mapview(occurrences_spatial)







