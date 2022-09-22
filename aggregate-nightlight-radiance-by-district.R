library(tidyverse)
library(terra)
library(sf)

# Aggregating São Paulo city districties nightlight radiance by median and by year====

# São Paulo districts shapefile
dist_sp <- sf::read_sf("shapefile/Bairros_Distritos_CidadeSP/LAYER_DISTRITO/DEINFO_DISTRITO.shp") %>% 
  dplyr::select(NOME_DIST, geometry) %>% 
  sf::st_transform(crs = 4326) 

# listing .tif files in a specified directory
tif_files <- list.files(path = "/Documents and Settings/gusaz/Documents/nightlight/nightlight-raster/median-masked/",
                        full.names = T)

# looping through .tif files, reading as raster with terra package, 
# raster cropping to just view the city of São Paulo 
# every element in the list is a raster from 2012 to 2016
nlt_list <- lapply(tif_files,
                   function(x){
                     nightlight <- terra::rast(x)
                     nightlight <- terra::crop(nightlight, dist_sp, mask = TRUE) %>% 
                       terra::mask(dist_sp)
                     return(nightlight)
                   })

# merging all the SpatRasters to create a single multilayered raster
# it makes easier some spatial data operations
nighttime_light_sp <- do.call(c, nlt_list)

# aggregate by district and by year using the median of the radiance 
nlt_all_years <- terra::extract(nighttime_light_sp, vect(dist_sp), fun = "median")

# put a year column and districts name variable



 





