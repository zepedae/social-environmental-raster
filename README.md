# Create a Raster with Human Social and Environmental Characteristics

This project is part of a larger study examining the human social characteristics and environmental characteristics shaping human-coyote interactions in the Chicago Metropolitan Area. These files use social data collected by the American Community Survey (US Census) and environmental data produced by the Chicago Metrpolitan Agency for Planning.

<img width="467" alt="image" src="https://user-images.githubusercontent.com/112019669/224872768-ba64b051-4af0-4a02-acfa-b0818710f4a4.png">


## Social Characteristics Using US Census Data
### create_social_rast.R
The social raster contains data on the socioeconomic and demographic characteristics
of people living in the Chicago Metropolitan Area. This file extracts American
Community Survey data on the income, race, and population density of designated 
areas using the tidycensus package. After extracting at the Census block group 
level, it rasterizes the spatial data to a resolution of 30 $m^{2}$.

### interpolate_social_rast.R
In urban areas, social system characteristics influence environmental 
characteristics beyond the residents' private property. For instance, pollutant 
concentrations tends to be negatively associated with an area's median income. 
Due to this spatial autocorrelation in the effect of human social characteristics 
on the environment, I conducted a kriging interpolation to estimate the social 
characteristics of areas with no human population e.g. city parks. Note: The 
interpolation is computationally intensive and was therefore performed on a 
supercomputing cluster.


## Environmental Characteristics Using CMAP Data
### create_env_rast.R
Using shapefile containing land use data from the Chicago Metropolitan Agency for 
Planning previously rasterized to a 300 $m^{2}$ resolution in QGIS, this file
loops over each cell in the raster calculating the proportion of natural habitat, 
disturbed habitat, and agriculture in a 1 km radius. A new environmental raster
brick is then generated with each layer containing the proportions of its habitat 
type.


## Final Raster
### combine_rasters.R
This file reprojects, resamples, and combines the social and environmental rasters
into one raster brick containing the social and environmental layers.
