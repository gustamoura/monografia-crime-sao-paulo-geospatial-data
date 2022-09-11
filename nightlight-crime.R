library(tidyverse)
library(terra)
library(sf)

# BASE=====
# geometria distritos de são paulo
dist_sp <- sf::read_sf("shapefile/Bairros_Distritos_CidadeSP/LAYER_DISTRITO/DEINFO_DISTRITO.shp") %>% 
  dplyr::select(NOME_DIST, geometry)

# crimes geolocalizados (roubos e furtos com latitude e longitude)
crime_sp <- readRDS("MONOGRAFIA/geospatial crime data SP/ocorrencias_crime_sp_coordinates.rds") %>% 
  dplyr::select(data_tidy, latitude, longitude) %>%  # apenas variáveis que interessam
  dplyr::filter(data_tidy >= "2012-01-01", data_tidy <= "2016-12-01") %>%  #período em que os dados estão bons
  sf::st_as_sf(coords = c("longitude", "latitude")) # transformando colunas de lat e long para geometria

# raster nightlight 2014
nightlight <- terra::rast("nightlight/VNL_v21_npp_2014_global_vcmslcfg_c202205302300.median_masked.dat.tif")

# mantendo mesmo sistema de coordenadas para raster e geometria dos distrito de sp
dist_sp <- sf::st_transform(dist_sp, crs(nightlight))

# mesmo sistema de coordenadas para geometria distrito e dataset de crimes
st_crs(crime_sp) <- st_crs(dist_sp)


# recortando raster apenas para cidade de são paulo=====
night_sp <- terra::crop(nightlight, dist_sp, mask = TRUE) %>% 
  terra::mask(dist_sp)

# JOIN pontos de crimes com geometria de são paulo com distritos=====
# para relacionar crime com distrito em que ocorreu
df <- sf::st_join(x = dist_sp, y = crime_sp)
# st_join acima retorna um dataset sem NAs e menor que crime_sp, ou seja, 
# elimina os pontos que estão fora da cidade de São Paulo

# obtendo quantidade de ocorrências de crime por distrito e ano=====
crime_sp_by_district <- df %>% 
  sf::st_drop_geometry() %>% # tirando geometria para group_by rodar mais rápido
  dplyr::group_by(ano = lubridate::year(data_tidy), NOME_DIST) %>% 
  dplyr::summarise(q_crime = n()) %>% 
  dplyr::ungroup()

# plotando série
ggplotly(

ggplot(data = crime_sp_by_district, aes(x = ano, y = q_crime, color = NOME_DIST))+
  geom_line()
)



