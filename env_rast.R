########################   Load Packages   #########################

library(sf)
library(sp)
library(terra)



##################   Calculate Prop Habitat Types   ##################

# load CMAP raster created in QGIS
rast <- rast("CMAP raster 300.tif")

# reassign CMAP categories to study categories
rast_matrix <- matrix(data = c(1, 1359, 0,
                      1359, 1361, 1, # disturbed habitat: cemetery
                      1361, 1398, 0,
                      1398, 1500, 1, # disturbed habitat: industry
                      1500, 1529, 1, # disturbed habitat: trans/comm/util/waste 
                      1529, 1530, 0, # don't include airports
                      1530, 1599, 1, # disturbed habitat: trans/comm/util/waste 
                      1599, 1999, 0,
                      1999, 2001, 2, # agriculture
                      2001, 2999, 0, 
                      2999, 3999, 3, #nature preserve
                      3999, 4999, 1, #disturbed habitat: vacant land
                      4999, 9999, 0), ncol = 3, byrow = TRUE)

env_rast <- classify(rast, rast_matrix)


values_temp <- data.frame("distProp" = rep(NA, ncell(env_rast)), 
                        "agProp" = rep(NA, ncell(env_rast)), 
                        "natProp" = rep(NA, ncell(env_rast)))


# loop through each cell creating a 1 km circle and calculating proportion
df <- lapply(1:ncell(env_rast), function(i) {
  center <- xyFromCell(env_rast, i)
  centroid <- SpatialPoints(coords = center, 
                            proj4string = sp::CRS("+init=EPSG:3435"), bbox = NULL)
  centroid_sf <- st_as_sf(centroid, wkt = "EPSG")
  buffer <- st_buffer(centroid_sf, 1000)
  buffer <- vect(buffer)
  values <- extract(env_rast, buffer)
  values <- na.omit(values)
  values_temp$distProp[i] <- sum(values$`CMAP raster 300` == 1)/nrow(values)
  values_temp$agProp[i] <- sum(values$`CMAP raster 300` == 2)/nrow(values)
  values_temp$natProp[i] <- sum(values$`CMAP raster 300` == 3)/nrow(values)
  return(values_temp[i,])
})

values <- do.call(rbind, df)

env_rast_prop <- env_rast

env_rast_prop$dist <- setValues(env_rast, values$distProp)
env_rast_prop$ag <- setValues(env_rast, values$agProp)
env_rast_prop$nat <- setValues(env_rast, values$natProp)



#################    Save Raster   #################
writeRaster(env_rast_prop, filename = "env_rast.grd", format="raster", 
            options="INTERLEAVE=BAND", overwrite = TRUE)
writeRaster(env_rast_prop, filename = "env_rastt.tif", 
            options="INTERLEAVE=BAND", overwrite = TRUE)
