###################    Load Packages   ##################

library(raster)


###################   Combine Rasters   ###################

social <- brick("social_rast_int.grd")
env <- brick("env_rast_prop")

# reproject social raster to env
social_proj <- projectRaster(social, env)

#sync resolution and extent
env_resamp <- resample(env, social_proj) 

#combine
final_rast <- stack(social_proj, env_resamp)




#################   Save Final Raster   ###################

writeRaster(finalRaster, filename = "final_raster.tif", format = "raster", 
            option = "INTERLEAVE=BAND", overwrite = TRUE)
writeRaster(finalRaster, filename = "final_raster.grd", format = "raster", 
            option = "INTERLEAVE=BAND", overwrite = TRUE)
            

