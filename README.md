# Create a Geospatial Raster with Human Social and Environmental Characteristics

This project is part of a larger study examining the human social characteristics and environmental characteristics shaping human-coyote interactions in the Chicago Metropolitan Area. These files use social data collected by the American Community Survey (US Census) and environmental data from the Chicago Metropolitan Agency for Planning (https://www.cmap.illinois.gov/data/land-use/inventory). 

The figure below shows a version of this raster that was used in an analysis of coyote behavioral data (Zepeda et al. 2023).

<img width="467" alt="image" src="https://user-images.githubusercontent.com/112019669/224872768-ba64b051-4af0-4a02-acfa-b0818710f4a4.png">


## Social Raster Using US Census Data
### create_social_rast.R
The social raster contains data on the socioeconomic and demographic characteristics
of people living in the Chicago Metropolitan Area. This file extracts American
Community Survey data on the income, race, and population density of designated 
areas using the tidycensus package. After extracting data at the Census block group 
level, it rasterizes the spatial data to a resolution of 30 $m^{2}$.

### interpolate_social_rast.R
In urban areas, social system characteristics influence environmental 
characteristics beyond the residents' private property. For instance, pollutant 
concentrations tend to be negatively associated with an area's median income. 
To account for this spatial autocorrelation in the effect of human social 
characteristics on the environment, this kriging interpolation estimates the social 
characteristics of areas with no human population e.g. city parks. Note: The 
interpolation is computationally intensive and was therefore performed on a 
supercomputing cluster.


## Environmental Raster Using CMAP Data
### create_env_rast.R
Using a shapefile containing land use data from the Chicago Metropolitan Agency for 
Planning previously rasterized to a 300 $m^{2}$ resolution in QGIS, this file
loops over each cell in the raster calculating the proportion of natural habitat, 
disturbed habitat, and agriculture in a 1 km radius. A new environmental raster
brick is then generated with each layer containing the proportions of its habitat 
type.


## Final Raster
### combine_rasters.R
This file reprojects, resamples, and combines the social and environmental rasters
into one raster brick containing layers for each characteristic.
