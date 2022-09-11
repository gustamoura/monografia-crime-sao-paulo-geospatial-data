library(sf)
library(raster)
library(dplyr)
library(spData)
library(spDataLarge)
library(tmap)    # for static and interactive maps
library(leaflet) # for interactive maps
library(ggplot2)

sp_shp <- sf::read_sf("shapefile/municipios_BR_2021/BR_Municipios_2021.shp") %>% 
  dplyr::filter(NM_MUN == "São Paulo")

df <- readRDS("ocorrencias_crime_sp_coordinates.rds") %>% 
  dplyr::select(data_tidy, latitude, longitude) %>% 
  dplyr::filter(data_tidy >= "2012-01-01", data_tidy <= "2016-12-01")

df_sf <- st_as_sf(df, coords = c("longitude", "latitude"))

st_crs(df_sf) <- st_crs(sp_shp)

sp_shp <- st_transform(sp_shp, crs = 4326)

df_sf <- st_transform(df_sf, crs = 4326)

st_join(df_sf, sp_shp)

######  
map_sp <- tm_shape(sp_shp) + tm_borders()

anim_sp <- map_sp + tm_shape(df_sf) + tm_dots() + tm_facets(along = "data_tidy", free.coords = F)

tmap_animation(anim_sp, filename = "teste.gif", delay = 25)
