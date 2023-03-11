### Combine population density and characteristics rasters ###

library(raster)  

popRaster <- stack("popDensRaster.tif") 
popRaster <- dropLayer(popRaster, 2)

socialRaster <- stack("socialRaster.tif") 

socialRasterResamp <- resample(socialRaster, popRaster)

finalSocialRaster <- stack(socialRasterResamp, popRaster)

names(finalSocialRaster) <- c("propW", "propL", "propB", "medInc", "propA","popDens")

writeRaster(finalSocialRaster, filename = "finalSocialRasterExpAllR.grd", options="INTERLEAVE=BAND", overwrite = TRUE)

writeRaster(finalSocialRaster, filename = "finalSocialRasterExpAllR.tif", options="INTERLEAVE=BAND", overwrite = TRUE)
