library(raster)
library(gstat)
library(sp)
library(rgeos)

# first crop raster to vhf and gps data with a 1000 m buffer
# load raster
socialRaster <- stack("socialCropBuffer.tif")

# Interpolate cropped raster

#load original social raster
socialRaster <- socialCrop


#create new raster for writing
rast <- socialRaster


#loop interpolates NA cells
for(x in 1:5){
  #get the coords of cells
  xy <- data.frame(xyFromCell(socialRaster, 1:ncell(socialRaster)))
  
  v <- getValues(socialRaster[[x]])
  
  i <- !is.na(v)
  xy <- xy[i,]
  v <- v[i]
  
  data <- cbind(xy, v)
  
  m <- gstat(id = "x", formula = v~1, locations = ~x+y, data = data, nmax = 100)
  
  rast[[x]] <- interpolate(socialRaster[[x]], m)
}

socialRaster <- rast

#write interpolated raster
writeRaster(socialRaster, filename = "socialRasterInt.tif", options="INTERLEAVE=BAND", overwrite = TRUE)
writeRaster(socialRaster, filename = "socialRasterInt.grd", format="raster", options="INTERLEAVE=BAND", overwrite = TRUE)




##here I'm going to also merge it with the pop raster and whatnot so it all happens at once
#popRaster <- stack("popDensRaster.tif") 
#
#socialRasterResamp <- resample(socialRaster, popRaster)
#
#finalSocialRaster <- stack(socialRasterResamp, popRaster)
#
#names(finalSocialRaster) <- c("propBach", "propW", "propL", "propB", "medInc", "propNat", "propA", "propPI", "popDens", "popDensSQ")
#
#writeRaster(finalSocialRaster, filename = "finalSocialRasterInt.grd", options="INTERLEAVE=BAND", overwrite = TRUE)
#
#writeRaster(finalSocialRaster, filename = "finalSocialRasterInt.tif", options="INTERLEAVE=BAND", overwrite = TRUE)
#