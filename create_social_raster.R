############   Load Packages   #############

library(tidycensus)
library(tidyverse)
library(sf)
library(sp)
library(raster)
library(terra)
library(geosphere)



###########   Load Census API Key   ###########

census_api_key("xxxxxxxxxxxxxxxxxxxxxxxxxxxx", install = TRUE, overwrite = TRUE)




#########  Extract Data from the 2012 American Community Survey   #############

# find Census variable codes
all_var <- load_variables(year = 2012, dataset = "acs5")

# variables of interest
vars <- data.frame(var_name = c("pop", "race_L", "race_W", "race_B", 
                                "race_N", "race_A", "med_inc"), 
                   code = c("B01003_001", "B03002_012", "B02001_002", 
                            "B02001_003", "B02001_004", "B02001_005", "B19113_001"))

# extract data
vars_list <- lapply(1:nrow(vars), function(i){
  name <- vars[i, 1]
  code <- vars[i, 2]
  data <- get_acs(geography = "block group", 
         variables = code, state = "IL",
         county = c("Cook County", "Kane County", "Dupage County", 
                    "McHenry", "Lake", "Will County"))
  
  colnames(data)[4] <- name
  
  # get block group area for metric calculation
  if(i == nrow(vars)){
    data$area <- st_area(get_acs(geography = "block group", 
                         variables = code, state = "IL",
                         county = c("Cook County", "Kane County", "Dupage County", 
                                    "McHenry", "Lake", "Will County"),
                         geometry = TRUE)$geometry)
  }
  
  return(data)
})



#################   Calculate Social Metrics   ##################

# calculate population density for each block group
vars_df <- vars_list %>% reduce(left_join, by="GEOID") %>% as.data.frame() %>% 
            mutate(pop_dens = as.numeric(pop/(area/1000000)), 
                              prop_a = race_A/pop, prop_b = race_B/pop, 
                              prop_l = race_L/pop, prop_n = race_N/pop, 
                              prop_w = race_W/pop) %>% 
            dplyr::select(prop_a,prop_b, prop_l, prop_b, prop_n, 
                          prop_w, pop_dens, med_inc, GEOID)




#################   Create Spatial Points Data Frame   ################

# get geometry, add row id (not GEOID bc too big), and combine with value data frame
vars_geom <- get_acs(geography = "block group", state = "IL", 
                variables = "B01003_001", county = c("Cook County", "Kane County", 
                                                     "Dupage County","McHenry", 
                                                     "Lake", "Will County"),
                geometry = TRUE) %>% dplyr::select(geometry, GEOID) %>% 
              mutate(ID = 1:nrow(.)) %>% 
              left_join(vars_df)

# create a SpatialPointsDataFrame to be rasterized
vars_geom <- vars_geom[na.omit(vars_geom$geometry), 
                       !colnames(vars_geom)== "GEOID"] # removes two empty geos
spdf <- sf::as_Spatial(st_geometry(vars_geom[, c("geometry", "ID")]), 
                       IDs = as.character(vars_geom$ID))
data <- st_drop_geometry(vars_geom)
#data <- data %>% mutate(row_names = unique(as.integer(ID))) # rasterize needs row_names

sp_df <- sp::SpatialPolygonsDataFrame(spdf, data = data)
sp_df <- spTransform(sp_df, CRS("+init=epsg:4269"))




########################  Rasterize SPDF   ##########################

# create raster template that has same approximate dimensions as SPDF
extent <- bbox(sp_df)
lon1 <- extent[1][1]
lon2 <- extent[3][1]
lat1 <- extent[2][1] 
lat2 <- extent[4][1]
length <- distm(c(lon1,lat1), c(lon1,lat2), fun=distVincentyEllipsoid)
width <- distm(c(lon1,lat1), c(lon2,lat1), fun=distVincentyEllipsoid)
rows <- length/30 # 30 m cell width/height
cols <- width/30
rast_temp <- raster(xmn=lon1, xmx=lon2, ymn=lat1, ymx=lat2, 
                      crs="+init=epsg:4269", ncol = cols, nrows = rows)

rast <- rasterize(sp_df, rast_temp, field = sp_df@data$ID) #burn-in geo value
rast <- as.factor(rast) # move id from layer to attributes
attributes <- levels(rast)[[1]] # create df with ids
attributes <- merge(attributes, data, by = "ID") # merge id df with the SPDF 
attributes$geometry <- NULL

levels(rast) <- attributes # assign the attributes to the existing raster
final_rast <- deratify(rast) # move from attributes to layers




###################   Save Final Social Raster   #################

# different file types are good for different things
writeRaster(final_rast, filename = "social_rast.grd", format="raster", options="INTERLEAVE=BAND", overwrite = TRUE)
writeRaster(final_rast, filename = "social_rast.tif", options="INTERLEAVE=BAND", overwrite = TRUE)

