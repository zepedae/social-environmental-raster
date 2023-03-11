######################   Load Packages   ######################

library(raster)
library(gstat)
library(sp)
library(rgeos)



######################   Interpolation   #######################

# load raster
soc_rast <- stack("social_rast.tif")

# new raster for writing
rast <- soc_rast

# loop interpolates NA cells
for(x in 1:5){
  #get the coords of cells
  xy <- data.frame(xyFromCell(soc_rast, 1:ncell(soc_rast)))
  
  v <- getValues(soc_rast[[x]])
  
  i <- !is.na(v)
  xy <- xy[i,]
  v <- v[i]
  
  data <- cbind(xy, v)
  
  m <- gstat(id = "x", formula = v~1, locations = ~x+y, data = data, nmax = 100)
  
  rast[[x]] <- interpolate(soc_rast[[x]], m)
}




##################   Save Interpolated Rastern  ##################
writeRaster(socialRaster, filename = "social_rastInt.tif", options="INTERLEAVE=BAND", 
            overwrite = TRUE)
writeRaster(socialRaster, filename = "social_rastInt.grd", format="raster", 
            options="INTERLEAVE=BAND", overwrite = TRUE)
